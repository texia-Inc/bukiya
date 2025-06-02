import React, { useState } from 'react';
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
  FormControl,
  FormLabel,
  RadioGroup,
  FormControlLabel,
  Radio,
  Chip,
} from '@mui/material';
import {
  Block as BanIcon,
  CheckCircle as UnbanIcon,
  Warning as WarningIcon,
} from '@mui/icons-material';
import { useBanPlayerMutation, useUnbanPlayerMutation } from '../services/api';

interface PlayerBanDialogProps {
  open: boolean;
  player: any | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const PlayerBanDialog: React.FC<PlayerBanDialogProps> = ({
  open,
  player,
  onClose,
  onSuccess,
}) => {
  const [banPlayer, { isLoading: isBanning, error: banError }] = useBanPlayerMutation();
  const [unbanPlayer, { isLoading: isUnbanning, error: unbanError }] = useUnbanPlayerMutation();
  
  const [banReason, setBanReason] = useState('');
  const [banDuration, setBanDuration] = useState('permanent');
  const [customDays, setCustomDays] = useState(7);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const isLoading = isBanning || isUnbanning;
  const error = banError || unbanError;

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (player?.is_active && !banReason.trim()) {
      newErrors.banReason = 'BAN理由は必須です';
    }

    if (player?.is_active && banDuration === 'custom' && customDays < 1) {
      newErrors.customDays = '日数は1日以上である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!player) return;

    if (player.is_active) {
      // BANの実行
      if (!validateForm()) return;

      let expiresAt: string | undefined;
      if (banDuration === 'temporary') {
        const expireDate = new Date();
        expireDate.setDate(expireDate.getDate() + customDays);
        expiresAt = expireDate.toISOString();
      }

      try {
        await banPlayer({
          id: player.id,
          reason: banReason,
          expires_at: expiresAt,
        }).unwrap();

        onSuccess();
        onClose();
        resetForm();
      } catch (err) {
        console.error('BAN実行エラー:', err);
      }
    } else {
      // BAN解除の実行
      try {
        await unbanPlayer(player.id).unwrap();

        onSuccess();
        onClose();
        resetForm();
      } catch (err) {
        console.error('BAN解除エラー:', err);
      }
    }
  };

  const resetForm = () => {
    setBanReason('');
    setBanDuration('permanent');
    setCustomDays(7);
    setErrors({});
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  if (!player) return null;

  const isBanAction = player.is_active;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        {isBanAction ? <BanIcon color="error" /> : <UnbanIcon color="success" />}
        {isBanAction ? 'プレイヤーBAN' : 'プレイヤーBAN解除'}
      </DialogTitle>
      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {isBanAction ? 'BANの実行に失敗しました' : 'BAN解除に失敗しました'}
          </Alert>
        )}

        <Stack spacing={3} sx={{ mt: 1 }}>
          {/* プレイヤー情報 */}
          <Box>
            <Typography variant="h6" gutterBottom>
              対象プレイヤー
            </Typography>
            <Box sx={{ p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
              <Typography variant="body1" fontWeight="medium">
                {player.username}
              </Typography>
              <Typography variant="body2" color="textSecondary">
                {player.email}
              </Typography>
              <Box sx={{ mt: 1 }}>
                <Chip
                  label={player.is_active ? 'アクティブ' : 'BAN済み'}
                  color={player.is_active ? 'success' : 'error'}
                  size="small"
                />
              </Box>
            </Box>
          </Box>

          {isBanAction ? (
            <>
              {/* BAN理由 */}
              <Box>
                <Typography variant="h6" gutterBottom>
                  BAN理由
                </Typography>
                <TextField
                  label="理由"
                  value={banReason}
                  onChange={(e) => {
                    setBanReason(e.target.value);
                    if (errors.banReason) {
                      setErrors(prev => ({ ...prev, banReason: '' }));
                    }
                  }}
                  error={!!errors.banReason}
                  helperText={errors.banReason}
                  fullWidth
                  multiline
                  rows={3}
                  placeholder="例: 不正行為、規約違反、迷惑行為など"
                  required
                />
              </Box>

              {/* BAN期間 */}
              <Box>
                <Typography variant="h6" gutterBottom>
                  BAN期間
                </Typography>
                <FormControl component="fieldset">
                  <RadioGroup
                    value={banDuration}
                    onChange={(e) => setBanDuration(e.target.value)}
                  >
                    <FormControlLabel
                      value="permanent"
                      control={<Radio />}
                      label="永久BAN"
                    />
                    <FormControlLabel
                      value="temporary"
                      control={<Radio />}
                      label="一時BAN"
                    />
                  </RadioGroup>
                </FormControl>

                {banDuration === 'temporary' && (
                  <Box sx={{ mt: 2, ml: 4 }}>
                    <TextField
                      label="BAN期間（日数）"
                      type="number"
                      value={customDays}
                      onChange={(e) => {
                        setCustomDays(parseInt(e.target.value) || 1);
                        if (errors.customDays) {
                          setErrors(prev => ({ ...prev, customDays: '' }));
                        }
                      }}
                      error={!!errors.customDays}
                      helperText={errors.customDays}
                      inputProps={{ min: 1, max: 365 }}
                      sx={{ width: 200 }}
                    />
                  </Box>
                )}
              </Box>

              {/* 警告 */}
              <Alert severity="warning" icon={<WarningIcon />}>
                <Typography variant="body2">
                  <strong>注意:</strong> BANされたプレイヤーはゲームにログインできなくなります。
                  {banDuration === 'permanent' 
                    ? ' 永久BANは管理者による手動解除が必要です。'
                    : ` ${customDays}日後に自動的にBAN解除されます。`
                  }
                </Typography>
              </Alert>
            </>
          ) : (
            <>
              {/* BAN解除確認 */}
              <Alert severity="info">
                <Typography variant="body2">
                  このプレイヤーのBANを解除しますか？
                  解除後、プレイヤーは再びゲームにログインできるようになります。
                </Typography>
              </Alert>
            </>
          )}
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>
          キャンセル
        </Button>
        <Button 
          onClick={handleSubmit}
          variant="contained"
          color={isBanAction ? 'error' : 'success'}
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading 
            ? (isBanAction ? 'BAN実行中...' : 'BAN解除中...')
            : (isBanAction ? 'BAN実行' : 'BAN解除')
          }
        </Button>
      </DialogActions>
    </Dialog>
  );
};
