import React from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Box,
  Alert,
  CircularProgress,
} from '@mui/material'
import { Warning as WarningIcon } from '@mui/icons-material'

interface MissionTemplate {
  id: number
  name: string
  description: string
  mission_type: 'daily' | 'weekly' | 'achievement'
  target_type: string
  target_count: number
  target_conditions: any
  reward_gold: number
  reward_exp: number
  reward_items: any
  is_active: boolean
  reset_schedule: string | null
  required_level: number
  display_order: number
  created_at: string
  updated_at: string
}

interface MissionDeleteDialogProps {
  open: boolean
  onClose: () => void
  template: MissionTemplate | null
  onConfirm: () => void
  isLoading: boolean
}

export const MissionDeleteDialog: React.FC<MissionDeleteDialogProps> = ({
  open,
  onClose,
  template,
  onConfirm,
  isLoading,
}) => {
  if (!template) return null

  const getMissionTypeLabel = (type: string) => {
    switch (type) {
      case 'daily': return 'デイリー'
      case 'weekly': return 'ウィークリー'
      case 'achievement': return 'アチーブメント'
      default: return type
    }
  }

  const getTargetTypeLabel = (type: string) => {
    switch (type) {
      case 'craft_weapon': return '武器作成'
      case 'sell_weapon': return '武器販売'
      case 'collect_material': return '素材収集'
      case 'dispatch_adventurer': return '冒険派遣'
      case 'login': return 'ログイン'
      case 'earn_gold': return 'ゴールド獲得'
      case 'upgrade_shop': return 'ショップアップグレード'
      default: return type
    }
  }

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        <Box display="flex" alignItems="center" gap={1}>
          <WarningIcon color="warning" />
          ミッションテンプレート削除
        </Box>
      </DialogTitle>
      <DialogContent>
        <Alert severity="warning" sx={{ mb: 2 }}>
          この操作は取り消すことができません。削除されたミッションテンプレートは復元できません。
        </Alert>
        
        <Typography variant="body1" gutterBottom>
          以下のミッションテンプレートを削除しますか？
        </Typography>
        
        <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
          <Typography variant="h6" gutterBottom>
            {template.name}
          </Typography>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            {template.description}
          </Typography>
          <Box sx={{ mt: 1 }}>
            <Typography variant="caption" display="block">
              <strong>ID:</strong> {template.id}
            </Typography>
            <Typography variant="caption" display="block">
              <strong>タイプ:</strong> {getMissionTypeLabel(template.mission_type)}
            </Typography>
            <Typography variant="caption" display="block">
              <strong>目標:</strong> {getTargetTypeLabel(template.target_type)} {template.target_count}個
            </Typography>
            <Typography variant="caption" display="block">
              <strong>報酬:</strong> {template.reward_gold}G + {template.reward_exp}経験値
            </Typography>
            <Typography variant="caption" display="block">
              <strong>状態:</strong> {template.is_active ? '有効' : '無効'}
            </Typography>
          </Box>
        </Box>

        {template.is_active && (
          <Alert severity="info" sx={{ mt: 2 }}>
            このミッションテンプレートは現在有効です。削除すると、関連するプレイヤーミッションにも影響する可能性があります。
          </Alert>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button
          onClick={onConfirm}
          color="error"
          variant="contained"
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={16} /> : null}
        >
          {isLoading ? '削除中...' : '削除'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}
