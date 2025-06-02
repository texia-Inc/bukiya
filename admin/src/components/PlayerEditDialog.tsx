import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Typography,
  Box,
  Stack,
  Alert,
  CircularProgress,
  Switch,
  FormControlLabel,
} from '@mui/material';
import {
  Edit as EditIcon,
} from '@mui/icons-material';
import { useUpdatePlayerMutation } from '../services/api';

interface PlayerEditDialogProps {
  open: boolean;
  player: any | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const PlayerEditDialog: React.FC<PlayerEditDialogProps> = ({
  open,
  player,
  onClose,
  onSuccess,
}) => {
  const [updatePlayer, { isLoading, error }] = useUpdatePlayerMutation();
  
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    gold: 0,
    gems: 0,
    shop_level: 1,
    reputation: 0,
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (player) {
      setFormData({
        username: player.username || '',
        email: player.email || '',
        gold: player.gold || 0,
        gems: player.gems || 0,
        shop_level: player.shop_level || 1,
        reputation: player.reputation || 0,
        is_active: player.is_active !== undefined ? player.is_active : true,
      });
      setErrors({});
    }
  }, [player]);

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.username.trim()) {
      newErrors.username = 'ユーザー名は必須です';
    } else if (formData.username.length < 3) {
      newErrors.username = 'ユーザー名は3文字以上である必要があります';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'メールアドレスは必須です';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = '有効なメールアドレスを入力してください';
    }

    if (formData.gold < 0) {
      newErrors.gold = 'ゴールドは0以上である必要があります';
    }

    if (formData.gems < 0) {
      newErrors.gems = 'ジェムは0以上である必要があります';
    }

    if (formData.shop_level < 1) {
      newErrors.shop_level = 'ショップレベルは1以上である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!validateForm() || !player) return;

    try {
      await updatePlayer({
        id: player.id,
        player: formData,
      }).unwrap();

      onSuccess();
      onClose();
    } catch (err) {
      console.error('プレイヤー更新エラー:', err);
    }
  };

  const handleInputChange = (field: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // エラーをクリア
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: '',
      }));
    }
  };

  const handleClose = () => {
    setErrors({});
    onClose();
  };

  if (!player) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <EditIcon />
        プレイヤー編集
      </DialogTitle>
      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            プレイヤーの更新に失敗しました
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
                label="ユーザー名"
                value={formData.username}
                onChange={(e) => handleInputChange('username', e.target.value)}
                error={!!errors.username}
                helperText={errors.username}
                fullWidth
                required
              />
              <TextField
                label="メールアドレス"
                type="email"
                value={formData.email}
                onChange={(e) => handleInputChange('email', e.target.value)}
                error={!!errors.email}
                helperText={errors.email}
                fullWidth
                required
              />
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.is_active}
                    onChange={(e) => handleInputChange('is_active', e.target.checked)}
                  />
                }
                label="アクティブ"
              />
            </Stack>
          </Box>

          {/* ゲーム進捗 */}
          <Box>
            <Typography variant="h6" gutterBottom>
              ゲーム進捗
            </Typography>
            <Stack spacing={2}>
              <TextField
                label="ゴールド"
                type="number"
                value={formData.gold}
                onChange={(e) => handleInputChange('gold', parseInt(e.target.value) || 0)}
                error={!!errors.gold}
                helperText={errors.gold}
                fullWidth
                inputProps={{ min: 0 }}
              />
              <TextField
                label="ジェム"
                type="number"
                value={formData.gems}
                onChange={(e) => handleInputChange('gems', parseInt(e.target.value) || 0)}
                error={!!errors.gems}
                helperText={errors.gems}
                fullWidth
                inputProps={{ min: 0 }}
              />
              <TextField
                label="ショップレベル"
                type="number"
                value={formData.shop_level}
                onChange={(e) => handleInputChange('shop_level', parseInt(e.target.value) || 1)}
                error={!!errors.shop_level}
                helperText={errors.shop_level}
                fullWidth
                inputProps={{ min: 1 }}
              />
              <TextField
                label="評判"
                type="number"
                value={formData.reputation}
                onChange={(e) => handleInputChange('reputation', parseInt(e.target.value) || 0)}
                fullWidth
              />
            </Stack>
          </Box>
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>
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
