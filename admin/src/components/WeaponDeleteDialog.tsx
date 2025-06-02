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
import { useDeleteWeaponMutation } from '../services/api';
import type { WeaponMaster } from '../types';

interface WeaponDeleteDialogProps {
  open: boolean;
  weapon: WeaponMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const WeaponDeleteDialog: React.FC<WeaponDeleteDialogProps> = ({
  open,
  weapon,
  onClose,
  onSuccess,
}) => {
  const [deleteWeapon, { isLoading }] = useDeleteWeaponMutation();
  const [submitError, setSubmitError] = useState<string>('');

  const handleDelete = async () => {
    if (!weapon) return;
    
    setSubmitError('');
    
    try {
      await deleteWeapon(weapon.id).unwrap();
      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('武器削除エラー:', error);
      setSubmitError(error?.data?.message || '武器の削除に失敗しました');
    }
  };

  const handleClose = () => {
    setSubmitError('');
    onClose();
  };

  if (!weapon) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle sx={{ color: 'error.main' }}>
        武器削除の確認
      </DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Typography variant="body1" sx={{ mb: 2 }}>
          以下の武器を削除してもよろしいですか？この操作は取り消せません。
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
            {weapon.name}
          </Typography>
          
          <Box sx={{ display: 'flex', gap: 1, mb: 1, flexWrap: 'wrap' }}>
            <Chip 
              label={weapon.weapon_type?.name || weapon.weapon_type_id} 
              size="small" 
              variant="outlined" 
            />
            <Chip
              label={weapon.rarity?.name || `Rarity ${weapon.rarity_id}`}
              size="small"
              sx={{
                backgroundColor: weapon.rarity?.color_code || '#9e9e9e',
                color: 'white',
              }}
            />
            {weapon.is_craftable && (
              <Chip 
                label="合成可能" 
                size="small" 
                color="success" 
                variant="outlined" 
              />
            )}
          </Box>

          <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
            {weapon.description || '説明なし'}
          </Typography>

          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Typography variant="body2">
              <strong>攻撃力:</strong> {weapon.base_attack}
            </Typography>
            <Typography variant="body2">
              <strong>価格:</strong> {weapon.base_price}G
            </Typography>
            <Typography variant="body2">
              <strong>必要レベル:</strong> Lv.{weapon.required_level}
            </Typography>
          </Box>
        </Box>

        <Alert severity="warning" sx={{ mt: 2 }}>
          <Typography variant="body2">
            <strong>注意:</strong> この武器を削除すると、以下の影響があります：
          </Typography>
          <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
            <li>プレイヤーが所持している同じ武器には影響しません</li>
            <li>合成レシピでこの武器を使用している場合、レシピが無効になる可能性があります</li>
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
