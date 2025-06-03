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

interface EnchantmentType {
  id?: number;
  name: string;
  description: string;
  effect_type: string;
  effect_value: number;
  max_level: number;
  base_success_rate: number;
  base_cost: number;
  required_materials: any;
  is_active: boolean;
}

interface EnchantmentTypeDialogProps {
  open: boolean;
  onClose: () => void;
  onSave: (data: EnchantmentType) => void;
  enchantmentType?: EnchantmentType | null;
  loading?: boolean;
}

const effectTypes = [
  { value: 'attack', label: '攻撃力' },
  { value: 'defense', label: '防御力' },
  { value: 'speed', label: '速度' },
  { value: 'critical', label: 'クリティカル' },
  { value: 'accuracy', label: '命中' },
  { value: 'durability', label: '耐久' },
];

const EnchantmentTypeDialog: React.FC<EnchantmentTypeDialogProps> = ({
  open,
  onClose,
  onSave,
  enchantmentType,
  loading = false,
}) => {
  const [formData, setFormData] = useState<EnchantmentType>({
    name: '',
    description: '',
    effect_type: 'attack',
    effect_value: 1.0,
    max_level: 10,
    base_success_rate: 0.8,
    base_cost: 1000,
    required_materials: {},
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (enchantmentType) {
      setFormData(enchantmentType);
    } else {
      setFormData({
        name: '',
        description: '',
        effect_type: 'attack',
        effect_value: 1.0,
        max_level: 10,
        base_success_rate: 0.8,
        base_cost: 1000,
        required_materials: {},
        is_active: true,
      });
    }
    setErrors({});
  }, [enchantmentType, open]);

  const handleChange = (field: keyof EnchantmentType) => (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const value = event.target.type === 'checkbox' 
      ? event.target.checked 
      : event.target.type === 'number'
      ? parseFloat(event.target.value) || 0
      : event.target.value;

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
      newErrors.name = 'エンチャント名は必須です';
    }

    if (!formData.description.trim()) {
      newErrors.description = '説明は必須です';
    }

    if (formData.effect_value <= 0) {
      newErrors.effect_value = '効果値は0より大きい値を入力してください';
    }

    if (formData.max_level <= 0 || formData.max_level > 100) {
      newErrors.max_level = '最大レベルは1-100の範囲で入力してください';
    }

    if (formData.base_success_rate <= 0 || formData.base_success_rate > 1) {
      newErrors.base_success_rate = '基本成功率は0.01-1.0の範囲で入力してください';
    }

    if (formData.base_cost <= 0) {
      newErrors.base_cost = '基本コストは0より大きい値を入力してください';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = () => {
    if (validateForm()) {
      onSave(formData);
    }
  };

  const isEdit = !!enchantmentType?.id;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? 'エンチャントタイプ編集' : 'エンチャントタイプ作成'}
      </DialogTitle>
      <DialogContent>
        <Box sx={{ mt: 2 }}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label="エンチャント名"
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
                label="効果タイプ"
                value={formData.effect_type}
                onChange={handleChange('effect_type')}
                required
              >
                {effectTypes.map((option) => (
                  <MenuItem key={option.value} value={option.value}>
                    {option.label}
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
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="効果値"
                value={formData.effect_value}
                onChange={handleChange('effect_value')}
                error={!!errors.effect_value}
                helperText={errors.effect_value || '武器に付与される効果の値'}
                inputProps={{ min: 0.1, step: 0.1 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="最大レベル"
                value={formData.max_level}
                onChange={handleChange('max_level')}
                error={!!errors.max_level}
                helperText={errors.max_level || 'エンチャント可能な最大レベル'}
                inputProps={{ min: 1, max: 100 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="基本成功率"
                value={formData.base_success_rate}
                onChange={handleChange('base_success_rate')}
                error={!!errors.base_success_rate}
                helperText={errors.base_success_rate || '0.01-1.0の範囲（例: 0.8 = 80%）'}
                inputProps={{ min: 0.01, max: 1.0, step: 0.01 }}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                type="number"
                label="基本コスト"
                value={formData.base_cost}
                onChange={handleChange('base_cost')}
                error={!!errors.base_cost}
                helperText={errors.base_cost || 'エンチャントに必要なゴールド'}
                inputProps={{ min: 1 }}
                required
              />
            </Grid>
            <Grid item xs={12}>
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
            <Typography variant="body2" color="text.secondary">
              {formData.name || '（エンチャント名）'} - {effectTypes.find(t => t.value === formData.effect_type)?.label}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              効果値: {formData.effect_value} | 最大Lv: {formData.max_level} | 成功率: {(formData.base_success_rate * 100).toFixed(1)}% | コスト: {formData.base_cost.toLocaleString()}G
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

export default EnchantmentTypeDialog;
