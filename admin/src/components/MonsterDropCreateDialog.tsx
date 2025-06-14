import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Box,
  Typography,
  Alert,
  Slider,
  Grid,
  Autocomplete,
  Chip,
} from '@mui/material';
import {
  useCreateMonsterDropMutation,
  useGetMaterialsQuery,
  useGetWeaponsQuery,
} from '../services/api';
import type { MonsterMaster, MonsterDropTableCreate } from '../types';

interface MonsterDropCreateDialogProps {
  open: boolean;
  monster: MonsterMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const MonsterDropCreateDialog: React.FC<MonsterDropCreateDialogProps> = ({
  open,
  monster,
  onClose,
  onSuccess,
}) => {
  const [formData, setFormData] = useState<MonsterDropTableCreate>({
    item_type: 'material',
    item_id: 0,
    drop_rate: 0.1,
    min_quantity: 1,
    max_quantity: 1,
    required_weapon_enchant: 0,
    required_adventurer_level: 0,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const [createMonsterDrop, { isLoading }] = useCreateMonsterDropMutation();
  
  // 素材とウェポンのデータを取得
  const { data: materialsResponse } = useGetMaterialsQuery({ page: 1, limit: 1000 });
  const { data: weaponsResponse } = useGetWeaponsQuery({ page: 1, limit: 1000 });

  const materials = materialsResponse?.data || [];
  const weapons = weaponsResponse?.data || [];

  const handleInputChange = (field: keyof MonsterDropTableCreate, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
    
    // エラーをクリア
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: ''
      }));
    }
  };

  const handleSubmit = async () => {
    // バリデーション
    const newErrors: Record<string, string> = {};
    
    if (formData.item_id === 0) {
      newErrors.item_id = 'アイテムを選択してください';
    }
    
    if (formData.drop_rate <= 0 || formData.drop_rate > 1) {
      newErrors.drop_rate = 'ドロップ率は0.1%～100%の間で設定してください';
    }
    
    if (formData.min_quantity < 1) {
      newErrors.min_quantity = '最小数量は1以上で設定してください';
    }
    
    if (formData.max_quantity < formData.min_quantity) {
      newErrors.max_quantity = '最大数量は最小数量以上で設定してください';
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    try {
      await createMonsterDrop({
        monster_id: monster!.id,
        drop: formData
      }).unwrap();
      
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('作成に失敗しました:', error);
      setErrors({ submit: 'ドロップアイテムの追加に失敗しました。' });
    }
  };

  const handleClose = () => {
    setFormData({
      item_type: 'material',
      item_id: 0,
      drop_rate: 0.1,
      min_quantity: 1,
      max_quantity: 1,
      required_weapon_enchant: 0,
      required_adventurer_level: 0,
    });
    setErrors({});
    onClose();
  };

  const getAvailableItems = () => {
    return formData.item_type === 'material' ? materials : weapons;
  };

  const getItemDisplayName = (item: any) => {
    if (formData.item_type === 'material') {
      return `${item.name} (${item.rarity?.name || 'Unknown'})`;
    } else {
      return `${item.name} (Lv.${item.required_level})`;
    }
  };

  const getRarityColor = (rarity: string) => {
    switch (rarity?.toLowerCase()) {
      case 'common': return '#9e9e9e';
      case 'uncommon': return '#4caf50';
      case 'rare': return '#2196f3';
      case 'epic': return '#9c27b0';
      case 'legendary': return '#ff9800';
      default: return '#9e9e9e';
    }
  };

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle>
        ドロップアイテム追加 - {monster?.name}
      </DialogTitle>
      <DialogContent>
        <Box sx={{ mt: 2 }}>
          {errors.submit && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {errors.submit}
            </Alert>
          )}

          <Grid container spacing={3}>
            {/* アイテム種別 */}
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth error={!!errors.item_type}>
                <InputLabel>アイテム種別</InputLabel>
                <Select
                  value={formData.item_type}
                  onChange={(e) => {
                    handleInputChange('item_type', e.target.value);
                    handleInputChange('item_id', 0); // リセット
                  }}
                  label="アイテム種別"
                >
                  <MenuItem value="material">素材</MenuItem>
                  <MenuItem value="weapon">武器</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            {/* アイテム選択 */}
            <Grid item xs={12} sm={6}>
              <Autocomplete
                options={getAvailableItems()}
                getOptionLabel={(option) => getItemDisplayName(option)}
                value={getAvailableItems().find(item => item.id === formData.item_id) || null}
                onChange={(_, value) => handleInputChange('item_id', value?.id || 0)}
                renderOption={(props, option) => (
                  <Box component="li" {...props}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Box
                        sx={{
                          width: 12,
                          height: 12,
                          borderRadius: '50%',
                          backgroundColor: getRarityColor(option.rarity?.name),
                        }}
                      />
                      {getItemDisplayName(option)}
                    </Box>
                  </Box>
                )}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    label={formData.item_type === 'material' ? '素材' : '武器'}
                    error={!!errors.item_id}
                    helperText={errors.item_id}
                  />
                )}
              />
            </Grid>

            {/* ドロップ率 */}
            <Grid item xs={12}>
              <Typography gutterBottom>
                ドロップ率: {(formData.drop_rate * 100).toFixed(1)}%
              </Typography>
              <Slider
                value={formData.drop_rate * 100}
                onChange={(_, value) => handleInputChange('drop_rate', (value as number) / 100)}
                min={0.1}
                max={100}
                step={0.1}
                marks={[
                  { value: 1, label: '1%' },
                  { value: 25, label: '25%' },
                  { value: 50, label: '50%' },
                  { value: 75, label: '75%' },
                  { value: 100, label: '100%' },
                ]}
              />
              {errors.drop_rate && (
                <Typography variant="caption" color="error">
                  {errors.drop_rate}
                </Typography>
              )}
            </Grid>

            {/* ドロップ数量 */}
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="最小ドロップ数量"
                type="number"
                value={formData.min_quantity}
                onChange={(e) => handleInputChange('min_quantity', parseInt(e.target.value) || 1)}
                inputProps={{ min: 1, max: 999 }}
                error={!!errors.min_quantity}
                helperText={errors.min_quantity}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="最大ドロップ数量"
                type="number"
                value={formData.max_quantity}
                onChange={(e) => handleInputChange('max_quantity', parseInt(e.target.value) || 1)}
                inputProps={{ min: 1, max: 999 }}
                error={!!errors.max_quantity}
                helperText={errors.max_quantity}
              />
            </Grid>

            {/* 条件設定 */}
            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom>
                ドロップ条件（オプション）
              </Typography>
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="必要武器強化レベル"
                type="number"
                value={formData.required_weapon_enchant}
                onChange={(e) => handleInputChange('required_weapon_enchant', parseInt(e.target.value) || 0)}
                inputProps={{ min: 0, max: 20 }}
                helperText="0の場合は条件なし"
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="必要冒険者レベル"
                type="number"
                value={formData.required_adventurer_level}
                onChange={(e) => handleInputChange('required_adventurer_level', parseInt(e.target.value) || 0)}
                inputProps={{ min: 0, max: 100 }}
                helperText="0の場合は条件なし"
              />
            </Grid>
          </Grid>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>キャンセル</Button>
        <Button 
          onClick={handleSubmit} 
          variant="contained"
          disabled={isLoading}
        >
          {isLoading ? '追加中...' : '追加'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};