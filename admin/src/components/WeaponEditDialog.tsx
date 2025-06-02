import React, { useState, useEffect } from 'react';
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
  FormControlLabel,
  Checkbox,
  Alert,
  CircularProgress,
  Box,
  Stack,
} from '@mui/material';
import { useUpdateWeaponMutation } from '../services/api';
import type { WeaponMaster } from '../types';

interface WeaponEditDialogProps {
  open: boolean;
  weapon: WeaponMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

interface WeaponFormData {
  name: string;
  description: string;
  weapon_type_id: string;
  rarity_id: number;
  base_attack: number;
  base_price: number;
  required_level: number;
  image_url: string;
  is_craftable: boolean;
}

const weaponTypes = [
  { id: 'sword', name: '剣' },
  { id: 'staff', name: '杖' },
  { id: 'bow', name: '弓' },
  { id: 'axe', name: '斧' },
  { id: 'dagger', name: '短剣' },
];

const rarities = [
  { id: 1, name: 'Common', color: '#9e9e9e' },
  { id: 2, name: 'Rare', color: '#2196f3' },
  { id: 3, name: 'Epic', color: '#9c27b0' },
  { id: 4, name: 'Legendary', color: '#ff9800' },
];

export const WeaponEditDialog: React.FC<WeaponEditDialogProps> = ({
  open,
  weapon,
  onClose,
  onSuccess,
}) => {
  const [updateWeapon, { isLoading }] = useUpdateWeaponMutation();
  const [formData, setFormData] = useState<WeaponFormData>({
    name: '',
    description: '',
    weapon_type_id: 'sword',
    rarity_id: 1,
    base_attack: 1,
    base_price: 100,
    required_level: 1,
    image_url: '',
    is_craftable: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');

  // 武器データが変更されたときにフォームを初期化
  useEffect(() => {
    if (weapon && open) {
      setFormData({
        name: weapon.name || '',
        description: weapon.description || '',
        weapon_type_id: weapon.weapon_type?.id || weapon.weapon_type_id || 'sword',
        rarity_id: weapon.rarity?.id || weapon.rarity_id || 1,
        base_attack: weapon.base_attack || 1,
        base_price: weapon.base_price || 100,
        required_level: weapon.required_level || 1,
        image_url: weapon.image_url || '',
        is_craftable: weapon.is_craftable !== undefined ? weapon.is_craftable : true,
      });
      setErrors({});
      setSubmitError('');
    }
  }, [weapon, open]);

  const handleInputChange = (field: keyof WeaponFormData, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = '武器名は必須です';
    }
    if (formData.base_attack < 1) {
      newErrors.base_attack = '攻撃力は1以上である必要があります';
    }
    if (formData.base_price < 0) {
      newErrors.base_price = '価格は0以上である必要があります';
    }
    if (formData.required_level < 1) {
      newErrors.required_level = '必要レベルは1以上である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!weapon) return;
    
    setSubmitError('');
    
    if (!validateForm()) {
      return;
    }

    try {
      await updateWeapon({ 
        id: weapon.id, 
        weapon: formData 
      }).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('武器更新エラー:', error);
      setSubmitError(error?.data?.message || '武器の更新に失敗しました');
    }
  };

  const handleClose = () => {
    setErrors({});
    setSubmitError('');
    onClose();
  };

  if (!weapon) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>武器編集: {weapon.name}</DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Stack spacing={2} sx={{ mt: 1 }}>
          <TextField
            fullWidth
            label="武器名"
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
            rows={3}
          />

          <Box sx={{ display: 'flex', gap: 2 }}>
            <FormControl fullWidth>
              <InputLabel>武器タイプ</InputLabel>
              <Select
                value={formData.weapon_type_id}
                label="武器タイプ"
                onChange={(e) => handleInputChange('weapon_type_id', e.target.value)}
              >
                {weaponTypes.map(type => (
                  <MenuItem key={type.id} value={type.id}>
                    {type.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl fullWidth>
              <InputLabel>レアリティ</InputLabel>
              <Select
                value={formData.rarity_id}
                label="レアリティ"
                onChange={(e) => handleInputChange('rarity_id', Number(e.target.value))}
              >
                {rarities.map(rarity => (
                  <MenuItem key={rarity.id} value={rarity.id}>
                    {rarity.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>

          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField
              fullWidth
              label="基本攻撃力"
              type="number"
              value={formData.base_attack}
              onChange={(e) => handleInputChange('base_attack', Number(e.target.value))}
              error={!!errors.base_attack}
              helperText={errors.base_attack}
              inputProps={{ min: 1 }}
              required
            />

            <TextField
              fullWidth
              label="基本価格"
              type="number"
              value={formData.base_price}
              onChange={(e) => handleInputChange('base_price', Number(e.target.value))}
              error={!!errors.base_price}
              helperText={errors.base_price}
              inputProps={{ min: 0 }}
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

          <TextField
            fullWidth
            label="画像URL"
            value={formData.image_url}
            onChange={(e) => handleInputChange('image_url', e.target.value)}
            placeholder="https://example.com/image.jpg"
          />

          <FormControlLabel
            control={
              <Checkbox
                checked={formData.is_craftable}
                onChange={(e) => handleInputChange('is_craftable', e.target.checked)}
              />
            }
            label="合成可能"
          />
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
          {isLoading ? '更新中...' : '更新'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
