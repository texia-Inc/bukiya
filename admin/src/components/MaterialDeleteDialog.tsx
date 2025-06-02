import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Alert,
  CircularProgress,
  Box,
  Chip,
} from '@mui/material';
import { useDeleteMaterialMutation } from '../services/api';
import type { MaterialMaster } from '../types';

interface MaterialDeleteDialogProps {
  open: boolean;
  material: MaterialMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const MaterialDeleteDialog: React.FC<MaterialDeleteDialogProps> = ({
  open,
  material,
  onClose,
  onSuccess,
}) => {
  const [deleteMaterial, { isLoading }] = useDeleteMaterialMutation();
  const [submitError, setSubmitError] = useState<string>('');

  const handleDelete = async () => {
    if (!material) return;
    
    setSubmitError('');
    
    try {
      await deleteMaterial(material.id).unwrap();
      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('素材削除エラー:', error);
      setSubmitError(error?.data?.message || '素材の削除に失敗しました');
    }
  };

  const handleClose = () => {
    setSubmitError('');
    onClose();
  };

  if (!material) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle sx={{ color: 'error.main' }}>
        素材削除の確認
      </DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Typography variant="body1" sx={{ mb: 2 }}>
          以下の素材を削除してもよろしいですか？この操作は取り消せません。
        </Typography>

        <Box 
          sx={{ 
            p: 2, 
            border: 1, 
            borderColor: 'divider', 
            borderRadius: 1,
            bgcolor: 'grey.50'
          }}
        >
          <Typography variant="h6" sx={{ mb: 1 }}>
            {material.name}
          </Typography>
          
          <Box sx={{ display: 'flex', gap: 1, mb: 1, flexWrap: 'wrap' }}>
            <Chip
              label={material.rarity?.name || `Rarity ${material.rarity_id}`}
              size="small"
              sx={{
                backgroundColor: material.rarity?.color_code || '#9e9e9e',
                color: 'white',
              }}
            />
          </Box>

          <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
            {material.description || '説明なし'}
          </Typography>

          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Typography variant="body2">
              <strong>価格:</strong> {material.base_price}G
            </Typography>
            <Typography variant="body2">
              <strong>最大スタック:</strong> {material.max_stack}個
            </Typography>
          </Box>
        </Box>

        <Alert severity="warning" sx={{ mt: 2 }}>
          <Typography variant="body2">
            <strong>注意:</strong> この素材を削除すると、以下の影響があります：
          </Typography>
          <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
            <li>プレイヤーが所持している同じ素材には影響しません</li>
            <li>合成レシピでこの素材を使用している場合、レシピが無効になる可能性があります</li>
            <li>削除後は復元できません</li>
          </ul>
        </Alert>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button 
          onClick={handleDelete} 
          color="error"
          variant="contained"
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading ? '削除中...' : '削除'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
