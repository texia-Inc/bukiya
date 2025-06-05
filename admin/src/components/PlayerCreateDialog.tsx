import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  FormControlLabel,
  Checkbox,
  Alert,
  CircularProgress,
  Box,
  Stack,
  Typography,
  InputAdornment,
} from '@mui/material';
import {
  Person as PersonIcon,
  Email as EmailIcon,
  Store as StoreIcon,
  MonetizationOn as GoldIcon,
  Diamond as GemIcon,
} from '@mui/icons-material';

interface PlayerCreateDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface PlayerFormData {
  username: string;
  email: string;
  shop_level: number;
  experience: number;
  gold: number;
  gems: number;
  is_active: boolean;
}

export const PlayerCreateDialog: React.FC<PlayerCreateDialogProps> = ({
  open,
  onClose,
  onSuccess,
}) => {
  const [formData, setFormData] = useState<PlayerFormData>({
    username: '',
    email: '',
    shop_level: 1,
    experience: 0,
    gold: 1000,
    gems: 0,
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (field: keyof PlayerFormData, value: any) => {
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

    if (!formData.username.trim()) {
      newErrors.username = 'ユーザー名は必須です';
    } else if (formData.username.length < 3) {
      newErrors.username = 'ユーザー名は3文字以上である必要があります';
    } else if (formData.username.length > 20) {
      newErrors.username = 'ユーザー名は20文字以下である必要があります';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'メールアドレスは必須です';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'メールアドレスの形式が正しくありません';
    }

    if (formData.shop_level < 1) {
      newErrors.shop_level = 'ショップレベルは1以上である必要があります';
    } else if (formData.shop_level > 100) {
      newErrors.shop_level = 'ショップレベルは100以下である必要があります';
    }

    if (formData.experience < 0) {
      newErrors.experience = '経験値は0以上である必要があります';
    }

    if (formData.gold < 0) {
      newErrors.gold = 'ゴールドは0以上である必要があります';
    }

    if (formData.gems < 0) {
      newErrors.gems = 'ジェムは0以上である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    setSubmitError('');
    
    if (!validateForm()) {
      return;
    }

    setIsLoading(true);
    try {
      // TODO: 実際のAPI呼び出しを実装
      // await createPlayer(formData).unwrap();
      
      // 現在はモック実装
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      console.log('プレイヤー作成:', formData);
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('プレイヤー作成エラー:', error);
      setSubmitError(error?.data?.message || 'プレイヤーの作成に失敗しました');
    } finally {
      setIsLoading(false);
    }
  };

  const handleClose = () => {
    // Reset form
    setFormData({
      username: '',
      email: '',
      shop_level: 1,
      experience: 0,
      gold: 1000,
      gems: 0,
      is_active: true,
    });
    setErrors({});
    setSubmitError('');
    onClose();
  };

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle>新規プレイヤー作成</DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Alert severity="info" sx={{ mb: 2 }}>
          新しいプレイヤーアカウントを作成します。プレイヤーは初回ログイン時にパスワードを設定します。
        </Alert>
        
        <Stack spacing={3} sx={{ mt: 1 }}>
          {/* アカウント情報 */}
          <Box>
            <Typography variant="h6" gutterBottom>アカウント情報</Typography>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="ユーザー名"
                value={formData.username}
                onChange={(e) => handleInputChange('username', e.target.value)}
                error={!!errors.username}
                helperText={errors.username || '3-20文字で入力してください'}
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <PersonIcon />
                    </InputAdornment>
                  ),
                }}
              />

              <TextField
                fullWidth
                label="メールアドレス"
                type="email"
                value={formData.email}
                onChange={(e) => handleInputChange('email', e.target.value)}
                error={!!errors.email}
                helperText={errors.email || 'ログイン用のメールアドレス'}
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <EmailIcon />
                    </InputAdornment>
                  ),
                }}
              />
            </Stack>
          </Box>

          {/* ゲーム進行状況 */}
          <Box>
            <Typography variant="h6" gutterBottom>初期ゲーム状況</Typography>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="ショップレベル"
                type="number"
                value={formData.shop_level}
                onChange={(e) => handleInputChange('shop_level', Number(e.target.value))}
                error={!!errors.shop_level}
                helperText={errors.shop_level || 'プレイヤーの初期ショップレベル (1-100)'}
                inputProps={{ min: 1, max: 100 }}
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <StoreIcon />
                    </InputAdornment>
                  ),
                }}
              />

              <TextField
                fullWidth
                label="経験値"
                type="number"
                value={formData.experience}
                onChange={(e) => handleInputChange('experience', Number(e.target.value))}
                error={!!errors.experience}
                helperText={errors.experience || '初期経験値'}
                inputProps={{ min: 0 }}
                required
              />
            </Stack>
          </Box>

          {/* 初期リソース */}
          <Box>
            <Typography variant="h6" gutterBottom>初期リソース</Typography>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="ゴールド"
                type="number"
                value={formData.gold}
                onChange={(e) => handleInputChange('gold', Number(e.target.value))}
                error={!!errors.gold}
                helperText={errors.gold || '初期所持ゴールド'}
                inputProps={{ min: 0 }}
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <GoldIcon />
                    </InputAdornment>
                  ),
                }}
              />

              <TextField
                fullWidth
                label="ジェム"
                type="number"
                value={formData.gems}
                onChange={(e) => handleInputChange('gems', Number(e.target.value))}
                error={!!errors.gems}
                helperText={errors.gems || 'プレミアム通貨'}
                inputProps={{ min: 0 }}
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <GemIcon />
                    </InputAdornment>
                  ),
                }}
              />
            </Stack>
          </Box>

          <FormControlLabel
            control={
              <Checkbox
                checked={formData.is_active}
                onChange={(e) => handleInputChange('is_active', e.target.checked)}
              />
            }
            label="アカウント有効"
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
          {isLoading ? '作成中...' : '作成'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};