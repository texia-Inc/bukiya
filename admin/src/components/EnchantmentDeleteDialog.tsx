import React from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Box,
  Alert,
} from '@mui/material';
import { Warning as WarningIcon } from '@mui/icons-material';

interface EnchantmentDeleteDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  itemName: string;
  itemType: 'type' | 'material';
  loading?: boolean;
}

const EnchantmentDeleteDialog: React.FC<EnchantmentDeleteDialogProps> = ({
  open,
  onClose,
  onConfirm,
  itemName,
  itemType,
  loading = false,
}) => {
  const getItemTypeLabel = () => {
    return itemType === 'type' ? 'エンチャントタイプ' : 'エンチャント素材';
  };

  const getWarningMessage = () => {
    if (itemType === 'type') {
      return 'このエンチャントタイプを削除すると、関連するエンチャント履歴やプレイヤーの武器エンチャントに影響する可能性があります。';
    } else {
      return 'このエンチャント素材を削除すると、プレイヤーの所持素材やエンチャントレシピに影響する可能性があります。';
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <WarningIcon color="warning" />
          {getItemTypeLabel()}の削除
        </Box>
      </DialogTitle>
      <DialogContent>
        <Box sx={{ mb: 2 }}>
          <Typography variant="body1" gutterBottom>
            以下の{getItemTypeLabel()}を削除しますか？
          </Typography>
          <Box
            sx={{
              p: 2,
              bgcolor: 'grey.100',
              borderRadius: 1,
              border: '1px solid',
              borderColor: 'grey.300',
            }}
          >
            <Typography variant="h6" color="text.primary">
              {itemName}
            </Typography>
          </Box>
        </Box>

        <Alert severity="warning" sx={{ mb: 2 }}>
          <Typography variant="body2">
            {getWarningMessage()}
          </Typography>
        </Alert>

        <Alert severity="error">
          <Typography variant="body2" fontWeight="bold">
            この操作は取り消すことができません。
          </Typography>
        </Alert>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={loading}>
          キャンセル
        </Button>
        <Button
          onClick={onConfirm}
          variant="contained"
          color="error"
          disabled={loading}
        >
          {loading ? '削除中...' : '削除する'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default EnchantmentDeleteDialog;
