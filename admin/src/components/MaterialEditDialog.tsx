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
  Alert,
  CircularProgress,
  Box,
  Stack,
} from '@mui/material';
import { useUpdateMaterialMutation } from '../services/api';
import type { MaterialMaster } from '../types';

interface MaterialEditDialogProps {
  open: boolean;
  material: MaterialMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

interface MaterialFormData {
  name: string;
  description: string;
  rarity_id: number;
  base_price: number;
  max_stack: number;
  image_url: string;
}

const rarities = [
  { id: 1, name: 'Common', color: '#9e9e9e' },
  { id: 2, name: 'Rare', color: '#2196f3' },
  { id: 3, name: 'Epic', color: '#9c27b0' },
  { id: 4, name: 'Legendary', color: '#ff9800' },
];

export const MaterialEditDialog: React.FC<MaterialEditDialogProps> = ({
  open,
  material,
  onClose,
  onSuccess,
}) => {
  const [updateMaterial, { isLoading }] = useUpdateMaterialMutation();
  const [formData, setFormData] = useState<MaterialFormData>({
    name: '',
    description: '',
    rarity_id: 1,
    base_price: 10,
    max_stack: 99,
    image_url: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');

  // 素材データが変更されたときにフォームを初期化
  useEffect(() => {
    if (material && open) {
      setFormData({
        name: material.name || '',
        description: material.description || '',
        rarity_id: material.rarity?.id || material.rarity_id || 1,
        base_price: material.base_price || 10,
        max_stack: material.max_stack || 99,
        image_url: material.image_url || '',
      });
      setErrors({});
      setSubmitError('');
    }
  }, [material, open]);

  const handleInputChange = (field: keyof MaterialFormData, value: any) => {
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
      newErrors.name = '素材名は必須です';
    }
    if (formData.base_price < 1) {
      newErrors.base_price = '価格は1以上である必要があります';
    }
    if (formData.max_stack < 1) {
      newErrors.max_stack = 'スタック数は1以上である必要があります';
    }
    if (formData.max_stack > 999) {
      newErrors.max_stack = 'スタック数は999以下である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!material) return;
    
    setSubmitError('');
    
    if (!validateForm()) {
      return;
    }

    try {
      await updateMaterial({ 
        id: material.id, 
        material: formData 
      }).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('素材更新エラー:', error);
      setSubmitError(error?.data?.message || '素材の更新に失敗しました');
    }
  };

  const handleClose = () => {
    setErrors({});
    setSubmitError('');
    onClose();
  };

  if (!material) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>素材編集: {material.name}</DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Stack spacing={2} sx={{ mt: 1 }}>
          <TextField
            fullWidth
            label="素材名"
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

          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField
              fullWidth
              label="基本価格"
              type="number"
              value={formData.base_price}
              onChange={(e) => handleInputChange('base_price', Number(e.target.value))}
              error={!!errors.base_price}
              helperText={errors.base_price}
              inputProps={{ min: 1 }}
              required
            />

            <TextField
              fullWidth
              label="最大スタック数"
              type="number"
              value={formData.max_stack}
              onChange={(e) => handleInputChange('max_stack', Number(e.target.value))}
              error={!!errors.max_stack}
              helperText={errors.max_stack}
              inputProps={{ min: 1, max: 999 }}
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
