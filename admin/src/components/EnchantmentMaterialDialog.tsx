import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Grid,
  MenuItem,
  FormControlLabel,
  Switch,
  Box,
  Typography,
  Alert,
} from '@mui/material';

interface EnchantmentMaterial {
  id?: number;
  name: string;
  description: string;
  rarity: string;
  effect_type: string | null;
  success_rate_bonus: number;
  cost_multiplier: number;
  max_stack: number;
  is_active: boolean;
}

interface EnchantmentMaterialDialogProps {
  open: boolean;
  onClose: () => void;
  onSave: (data: EnchantmentMaterial) => void;
  material?: EnchantmentMaterial | null;
  loading?: boolean;
}

const rarityTypes = [
  { value: 'common', label: 'コモン' },
  { value: 'uncommon', label: 'アンコモン' },
  { value: 'rare', label: 'レア' },
  { value: 'epic', label: 'エピック' },
  { value: 'legendary', label: 'レジェンダリー' },
];

const effectTypes = [
  { value: '', label: '汎用（すべてのエンチャントに使用可能）' },
  { value: 'attack', label: '攻撃力エンチャント専用' },
  { value: 'defense', label: '防御力エンチャント専用' },
  { value: 'speed', label: '速度エンチャント専用' },
  { value: 'critical', label: 'クリティカルエンチャント専用' },
  { value: 'accuracy', label: '命中エンチャント専用' },
  { value: 'durability', label: '耐久エンチャント専用' },
];

const EnchantmentMaterialDialog: React.FC<EnchantmentMaterialDialogProps> = ({
  open,
  onClose,
  onSave,
  material,
  loading = false,
}) => {
  const [formData, setFormData] = useState<EnchantmentMaterial>({
    name: '',
    description: '',
    rarity: 'common',
    effect_type: null,
    success_rate_bonus: 0.05,
    cost_multiplier: 1.0,
    max_stack: 999,
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (material) {
      setFormData(material);
    } else {
      setFormData({
        name: '',
        description: '',
        rarity: 'common',
        effect_type: null,
        success_rate_bonus: 0.05,
        cost_multiplier: 1.0,
        max_stack: 999,
        is_active: true,
      });
    }
    setErrors({});
  }, [material, open]);

  const handleChange = (field: keyof EnchantmentMaterial) => (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    let value: any = event.target.value;

    if (event.target.type === 'checkbox') {
      value = event.target.checked;
    } else if (event.target.type === 'number') {
      value = parseFloat(event.target.value) || 0;
    } else if (field === 'effect_type' && value === '') {
      value = null;
    }

    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));

    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: '',
      }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = '素材名は必須です';
    }

    if (!formData.description.trim()) {
      newErrors.description = '説明は必須です';
    }

    if (formData.success_rate_bonus < 0 || formData.success_rate_bonus > 1) {
      newErrors.success_rate_bonus = '成功率ボーナスは0.0-1.0の範囲で入力してください';
    }

    if (formData.cost_multiplier <= 0 || formData.cost_multiplier > 10) {
      newErrors.cost_multiplier = 'コスト倍率は0.1-10.0の範囲で入力してください';
    }

    if (formData.max_stack <= 0 || formData.max_stack > 9999) {
      newErrors.max_stack = '最大所持数は1-9999の範囲で入力してください';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = () => {
    if (validateForm()) {
      onSave(formData);
    }
  };

  const isEdit = !!material?.id;

  const getRarityColor = (rarity: string) => {
    switch (rarity) {
      case 'common': return '#9e9e9e';
      case 'uncommon': return '#2196f3';
      case 'rare': return '#9c27b0';
      case 'epic': return '#ff9800';
      case 'legendary': return '#f44336';
      default: return '#9e9e9e';
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? 'エンチャント素材編集' : 'エンチャント素材作成'}
      </DialogTitle>
      <DialogContent>
        <Box sx={{ mt: 2 }}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label="素材名"
                value={formData.name}
                onChange={handleChange('name')}
                error={!!errors.name}
                helperText={errors.name}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                select
                label="レアリティ"
                value={formData.rarity}
                onChange={handleChange('rarity')}
                required
              >
                {rarityTypes.map((option) => (
                  <MenuItem key={option.value} value={option.value}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Box
                        sx={{
                          width: 12,
                          height: 12,
                          borderRadius: '50%',
                          bgcolor: getRarityColor(option.value),
                        }}
                      />
                      {option.label}
                    </Box>
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={3}
                label="説明"
                value={formData.description}
                onChange={handleChange('description')}
                error={!!errors.description}
                helperText={errors.description}
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                select
                label="効果タイプ"
                value={formData.effect_type || ''}
                onChange={handleChange('effect_type')}
                helperText="特定のエンチャントタイプ専用にするか、汎用にするかを選択"
              >
                {effectTypes.map((option) => (
                  <MenuItem key={option.value} value={option.value}>
                    {option.label}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="成功率ボーナス"
                value={formData.success_rate_bonus}
                onChange={handleChange('success_rate_bonus')}
                error={!!errors.success_rate_bonus}
                helperText={errors.success_rate_bonus || '0.0-1.0の範囲（例: 0.05 = +5%）'}
                inputProps={{ min: 0, max: 1.0, step: 0.01 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="コスト倍率"
                value={formData.cost_multiplier}
                onChange={handleChange('cost_multiplier')}
                error={!!errors.cost_multiplier}
                helperText={errors.cost_multiplier || 'エンチャントコストの倍率（例: 1.5 = 1.5倍）'}
                inputProps={{ min: 0.1, max: 10.0, step: 0.1 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="最大所持数"
                value={formData.max_stack}
                onChange={handleChange('max_stack')}
                error={!!errors.max_stack}
                helperText={errors.max_stack || 'プレイヤーが所持できる最大数'}
                inputProps={{ min: 1, max: 9999 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.is_active}
                    onChange={handleChange('is_active')}
                  />
                }
                label="有効"
              />
            </Grid>
          </Grid>

          {Object.keys(errors).length > 0 && (
            <Alert severity="error" sx={{ mt: 2 }}>
              入力内容を確認してください
            </Alert>
          )}

          <Box sx={{ mt: 3, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
            <Typography variant="subtitle2" gutterBottom>
              プレビュー
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
              <Box
                sx={{
                  width: 16,
                  height: 16,
                  borderRadius: '50%',
                  bgcolor: getRarityColor(formData.rarity),
                }}
              />
              <Typography variant="body2" fontWeight="bold">
                {formData.name || '（素材名）'}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                - {rarityTypes.find(r => r.value === formData.rarity)?.label}
              </Typography>
            </Box>
            <Typography variant="body2" color="text.secondary">
              効果: {formData.effect_type ? effectTypes.find(e => e.value === formData.effect_type)?.label : '汎用'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              成功率: +{(formData.success_rate_bonus * 100).toFixed(1)}% | 
              コスト: ×{formData.cost_multiplier} | 
              最大所持: {formData.max_stack.toLocaleString()}個
            </Typography>
          </Box>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={loading}>
          キャンセル
        </Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={loading}
        >
          {loading ? '保存中...' : isEdit ? '更新' : '作成'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default EnchantmentMaterialDialog;
