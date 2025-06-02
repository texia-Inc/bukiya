import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
  CircularProgress,
  Box,
  Stack,
  Typography,
  Card,
  CardContent,
  IconButton,
  Chip,
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import { useCreateRecipeMutation, useGetWeaponsQuery, useGetMaterialsQuery } from '../services/api';

interface RecipeCreateDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface RecipeMaterial {
  material_id: number;
  quantity: number;
}

interface RecipeFormData {
  weapon_id: number;
  name: string;
  description: string;
  gold_cost: number;
  success_rate: number;
  required_level: number;
  materials: RecipeMaterial[];
}

export const RecipeCreateDialog: React.FC<RecipeCreateDialogProps> = ({
  open,
  onClose,
  onSuccess,
}) => {
  const [createRecipe, { isLoading }] = useCreateRecipeMutation();
  const { data: weaponsData } = useGetWeaponsQuery({});
  const { data: materialsData } = useGetMaterialsQuery({});
  
  const [formData, setFormData] = useState<RecipeFormData>({
    weapon_id: 0,
    name: '',
    description: '',
    gold_cost: 100,
    success_rate: 0.8,
    required_level: 1,
    materials: [],
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');

  // モックデータ
  const mockWeapons = [
    { id: 1, name: '鉄の剣', weapon_type: { name: '剣' }, rarity: { name: 'Common' } },
    { id: 2, name: '鋼鉄の剣', weapon_type: { name: '剣' }, rarity: { name: 'Uncommon' } },
    { id: 3, name: '炎の杖', weapon_type: { name: '杖' }, rarity: { name: 'Rare' } },
  ];

  const mockMaterials = [
    { id: 1, name: '鉄鉱石', rarity: { name: 'Common', color_code: '#9e9e9e' } },
    { id: 2, name: '魔法の水晶', rarity: { name: 'Rare', color_code: '#2196f3' } },
    { id: 3, name: 'ドラゴンの鱗', rarity: { name: 'Epic', color_code: '#9c27b0' } },
    { id: 4, name: '古代の木材', rarity: { name: 'Uncommon', color_code: '#4caf50' } },
    { id: 5, name: '氷の欠片', rarity: { name: 'Rare', color_code: '#2196f3' } },
  ];

  const weapons = weaponsData?.data || mockWeapons;
  const materials = materialsData?.data || mockMaterials;

  const handleInputChange = (field: keyof Omit<RecipeFormData, 'materials'>, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const handleAddMaterial = () => {
    setFormData(prev => ({
      ...prev,
      materials: [...prev.materials, { material_id: 0, quantity: 1 }],
    }));
  };

  const handleRemoveMaterial = (index: number) => {
    setFormData(prev => ({
      ...prev,
      materials: prev.materials.filter((_, i) => i !== index),
    }));
  };

  const handleMaterialChange = (index: number, field: keyof RecipeMaterial, value: number) => {
    setFormData(prev => ({
      ...prev,
      materials: prev.materials.map((material, i) => 
        i === index ? { ...material, [field]: value } : material
      ),
    }));
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = 'レシピ名は必須です';
    }
    if (formData.weapon_id === 0) {
      newErrors.weapon_id = '武器を選択してください';
    }
    if (formData.gold_cost < 0) {
      newErrors.gold_cost = 'ゴールドコストは0以上である必要があります';
    }
    if (formData.success_rate < 0 || formData.success_rate > 1) {
      newErrors.success_rate = '成功率は0.0〜1.0の範囲で入力してください';
    }
    if (formData.required_level < 1) {
      newErrors.required_level = '必要レベルは1以上である必要があります';
    }
    if (formData.materials.length === 0) {
      newErrors.materials = '少なくとも1つの素材を追加してください';
    }

    // 素材の検証
    formData.materials.forEach((material, index) => {
      if (material.material_id === 0) {
        newErrors[`material_${index}`] = '素材を選択してください';
      }
      if (material.quantity < 1) {
        newErrors[`quantity_${index}`] = '数量は1以上である必要があります';
      }
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    setSubmitError('');
    
    if (!validateForm()) {
      return;
    }

    try {
      await createRecipe(formData).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('レシピ作成エラー:', error);
      setSubmitError(error?.data?.message || 'レシピの作成に失敗しました');
    }
  };

  const handleClose = () => {
    // Reset form
    setFormData({
      weapon_id: 0,
      name: '',
      description: '',
      gold_cost: 100,
      success_rate: 0.8,
      required_level: 1,
      materials: [],
    });
    setErrors({});
    setSubmitError('');
    onClose();
  };

  const selectedWeapon = weapons.find(w => w.id === formData.weapon_id);

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>新規レシピ作成</DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Stack spacing={3} sx={{ mt: 1 }}>
          {/* 基本情報 */}
          <Box>
            <Typography variant="h6" gutterBottom>
              基本情報
            </Typography>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="レシピ名"
                value={formData.name}
                onChange={(e) => handleInputChange('name', e.target.value)}
                error={!!errors.name}
                helperText={errors.name}
                required
              />

              <TextField
                fullWidth
                label="説明"
                value={formData.description}
                onChange={(e) => handleInputChange('description', e.target.value)}
                multiline
                rows={2}
              />

              <FormControl fullWidth error={!!errors.weapon_id}>
                <InputLabel>対象武器 *</InputLabel>
                <Select
                  value={formData.weapon_id}
                  label="対象武器 *"
                  onChange={(e) => handleInputChange('weapon_id', Number(e.target.value))}
                >
                  <MenuItem value={0}>武器を選択してください</MenuItem>
                  {weapons.map(weapon => (
                    <MenuItem key={weapon.id} value={weapon.id}>
                      {weapon.name} ({weapon.weapon_type?.name}) - {weapon.rarity?.name}
                    </MenuItem>
                  ))}
                </Select>
                {errors.weapon_id && (
                  <Typography variant="caption" color="error" sx={{ mt: 0.5, ml: 1.5 }}>
                    {errors.weapon_id}
                  </Typography>
                )}
              </FormControl>

              {selectedWeapon && (
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="subtitle2" color="primary">
                      選択された武器
                    </Typography>
                    <Typography variant="body2">
                      {selectedWeapon.name} - {selectedWeapon.weapon_type?.name} ({selectedWeapon.rarity?.name})
                    </Typography>
                  </CardContent>
                </Card>
              )}
            </Stack>
          </Box>

          {/* レシピ設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>
              レシピ設定
            </Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="ゴールドコスト"
                type="number"
                value={formData.gold_cost}
                onChange={(e) => handleInputChange('gold_cost', Number(e.target.value))}
                error={!!errors.gold_cost}
                helperText={errors.gold_cost}
                inputProps={{ min: 0 }}
                required
              />

              <TextField
                fullWidth
                label="成功率"
                type="number"
                value={formData.success_rate}
                onChange={(e) => handleInputChange('success_rate', Number(e.target.value))}
                error={!!errors.success_rate}
                helperText={errors.success_rate || "0.0〜1.0の範囲で入力"}
                inputProps={{ min: 0, max: 1, step: 0.1 }}
                required
              />

              <TextField
                fullWidth
                label="必要レベル"
                type="number"
                value={formData.required_level}
                onChange={(e) => handleInputChange('required_level', Number(e.target.value))}
                error={!!errors.required_level}
                helperText={errors.required_level}
                inputProps={{ min: 1 }}
                required
              />
            </Box>
          </Box>

          {/* 必要素材 */}
          <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
              <Typography variant="h6">
                必要素材
              </Typography>
              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={handleAddMaterial}
                size="small"
              >
                素材追加
              </Button>
            </Box>

            {errors.materials && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {errors.materials}
              </Alert>
            )}

            <Stack spacing={2}>
              {formData.materials.map((material, index) => {
                const selectedMaterial = materials.find(m => m.id === material.material_id);
                return (
                  <Card key={index} variant="outlined">
                    <CardContent>
                      <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start' }}>
                        <FormControl fullWidth error={!!errors[`material_${index}`]}>
                          <InputLabel>素材</InputLabel>
                          <Select
                            value={material.material_id}
                            label="素材"
                            onChange={(e) => handleMaterialChange(index, 'material_id', Number(e.target.value))}
                          >
                            <MenuItem value={0}>素材を選択してください</MenuItem>
                            {materials.map(mat => (
                              <MenuItem key={mat.id} value={mat.id}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                  <Chip
                                    label={mat.rarity?.name}
                                    size="small"
                                    sx={{
                                      backgroundColor: mat.rarity?.color_code,
                                      color: 'white',
                                      minWidth: 60,
                                    }}
                                  />
                                  {mat.name}
                                </Box>
                              </MenuItem>
                            ))}
                          </Select>
                          {errors[`material_${index}`] && (
                            <Typography variant="caption" color="error" sx={{ mt: 0.5 }}>
                              {errors[`material_${index}`]}
                            </Typography>
                          )}
                        </FormControl>

                        <TextField
                          label="数量"
                          type="number"
                          value={material.quantity}
                          onChange={(e) => handleMaterialChange(index, 'quantity', Number(e.target.value))}
                          error={!!errors[`quantity_${index}`]}
                          helperText={errors[`quantity_${index}`]}
                          inputProps={{ min: 1 }}
                          sx={{ minWidth: 100 }}
                        />

                        <IconButton
                          color="error"
                          onClick={() => handleRemoveMaterial(index)}
                          sx={{ mt: 1 }}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </Box>

                      {selectedMaterial && (
                        <Box sx={{ mt: 1 }}>
                          <Typography variant="caption" color="textSecondary">
                            選択中: {selectedMaterial.name} ({selectedMaterial.rarity?.name})
                          </Typography>
                        </Box>
                      )}
                    </CardContent>
                  </Card>
                );
              })}

              {formData.materials.length === 0 && (
                <Box sx={{ textAlign: 'center', py: 3, color: 'text.secondary' }}>
                  <Typography variant="body2">
                    「素材追加」ボタンをクリックして必要素材を追加してください
                  </Typography>
                </Box>
              )}
            </Stack>
          </Box>
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button 
          onClick={handleSubmit} 
          variant="contained" 
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading ? '作成中...' : '作成'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
