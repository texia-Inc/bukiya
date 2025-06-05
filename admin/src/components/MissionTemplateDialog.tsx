import React, { useState, useEffect } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid,
  Box,
  Typography,
  Switch,
  FormControlLabel,
  Alert,
  CircularProgress,
} from '@mui/material'
import {
  useCreateMissionTemplateMutation,
  useUpdateMissionTemplateMutation,
} from '../services/api'

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

interface MissionTemplateDialogProps {
  open: boolean
  onClose: () => void
  template: MissionTemplate | null
  onSuccess?: () => void
}

export const MissionTemplateDialog: React.FC<MissionTemplateDialogProps> = ({
  open,
  onClose,
  template,
  onSuccess,
}) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    mission_type: 'daily' as 'daily' | 'weekly' | 'achievement',
    target_type: 'craft_weapon',
    target_count: 1,
    reward_gold: 0,
    reward_exp: 0,
    is_active: true,
    required_level: 1,
    display_order: 0,
  })

  const [errors, setErrors] = useState<Record<string, string>>({})
  
  // API mutations
  const [createMissionTemplate, { isLoading: isCreating }] = useCreateMissionTemplateMutation()
  const [updateMissionTemplate, { isLoading: isUpdating }] = useUpdateMissionTemplateMutation()
  
  const isLoading = isCreating || isUpdating

  useEffect(() => {
    if (template) {
      setFormData({
        name: template.name,
        description: template.description,
        mission_type: template.mission_type,
        target_type: template.target_type,
        target_count: template.target_count,
        reward_gold: template.reward_gold,
        reward_exp: template.reward_exp,
        is_active: template.is_active,
        required_level: template.required_level,
        display_order: template.display_order,
      })
    } else {
      setFormData({
        name: '',
        description: '',
        mission_type: 'daily',
        target_type: 'craft_weapon',
        target_count: 1,
        reward_gold: 0,
        reward_exp: 0,
        is_active: true,
        required_level: 1,
        display_order: 0,
      })
    }
    setErrors({})
  }, [template, open])

  const handleChange = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }))
    }
  }

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.name.trim()) {
      newErrors.name = 'ミッション名は必須です'
    }
    if (!formData.description.trim()) {
      newErrors.description = 'ミッション説明は必須です'
    }
    if (formData.target_count < 1) {
      newErrors.target_count = '目標数は1以上である必要があります'
    }
    if (formData.reward_gold < 0) {
      newErrors.reward_gold = '報酬ゴールドは0以上である必要があります'
    }
    if (formData.reward_exp < 0) {
      newErrors.reward_exp = '報酬経験値は0以上である必要があります'
    }
    if (formData.required_level < 1) {
      newErrors.required_level = '必要レベルは1以上である必要があります'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!validateForm()) {
      return
    }

    try {
      if (template) {
        // 更新
        await updateMissionTemplate({ 
          id: template.id, 
          template: formData 
        }).unwrap()
      } else {
        // 新規作成
        await createMissionTemplate(formData).unwrap()
      }
      
      onSuccess?.()
      onClose()
    } catch (error) {
      console.error('ミッションテンプレートの保存に失敗しました:', error)
      // エラーハンドリングは必要に応じて追加
    }
  }

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
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {template ? 'ミッションテンプレート編集' : 'ミッションテンプレート作成'}
      </DialogTitle>
      <DialogContent>
        <Box sx={{ mt: 2 }}>
          <Grid container spacing={3}>
            {/* 基本情報 */}
            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom>
                基本情報
              </Typography>
            </Grid>
            
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="ミッション名"
                value={formData.name}
                onChange={(e) => handleChange('name', e.target.value)}
                error={!!errors.name}
                helperText={errors.name}
                required
              />
            </Grid>

            <Grid item xs={12}>
              <TextField
                fullWidth
                label="ミッション説明"
                value={formData.description}
                onChange={(e) => handleChange('description', e.target.value)}
                error={!!errors.description}
                helperText={errors.description}
                multiline
                rows={3}
                required
              />
            </Grid>

            <Grid item xs={6}>
              <FormControl fullWidth>
                <InputLabel>ミッションタイプ</InputLabel>
                <Select
                  value={formData.mission_type}
                  label="ミッションタイプ"
                  onChange={(e) => handleChange('mission_type', e.target.value)}
                >
                  <MenuItem value="daily">デイリー</MenuItem>
                  <MenuItem value="weekly">ウィークリー</MenuItem>
                  <MenuItem value="achievement">アチーブメント</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={6}>
              <FormControl fullWidth>
                <InputLabel>目標タイプ</InputLabel>
                <Select
                  value={formData.target_type}
                  label="目標タイプ"
                  onChange={(e) => handleChange('target_type', e.target.value)}
                >
                  <MenuItem value="craft_weapon">武器作成</MenuItem>
                  <MenuItem value="sell_weapon">武器販売</MenuItem>
                  <MenuItem value="collect_material">素材収集</MenuItem>
                  <MenuItem value="dispatch_adventurer">冒険派遣</MenuItem>
                  <MenuItem value="login">ログイン</MenuItem>
                  <MenuItem value="earn_gold">ゴールド獲得</MenuItem>
                  <MenuItem value="upgrade_shop">ショップアップグレード</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="目標数"
                type="number"
                value={formData.target_count}
                onChange={(e) => handleChange('target_count', parseInt(e.target.value) || 0)}
                error={!!errors.target_count}
                helperText={errors.target_count}
                inputProps={{ min: 1 }}
                required
              />
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="必要プレイヤーレベル"
                type="number"
                value={formData.required_level}
                onChange={(e) => handleChange('required_level', parseInt(e.target.value) || 1)}
                error={!!errors.required_level}
                helperText={errors.required_level}
                inputProps={{ min: 1 }}
                required
              />
            </Grid>

            {/* 報酬設定 */}
            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom sx={{ mt: 2 }}>
                報酬設定
              </Typography>
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="報酬ゴールド"
                type="number"
                value={formData.reward_gold}
                onChange={(e) => handleChange('reward_gold', parseInt(e.target.value) || 0)}
                error={!!errors.reward_gold}
                helperText={errors.reward_gold}
                inputProps={{ min: 0 }}
              />
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="報酬経験値"
                type="number"
                value={formData.reward_exp}
                onChange={(e) => handleChange('reward_exp', parseInt(e.target.value) || 0)}
                error={!!errors.reward_exp}
                helperText={errors.reward_exp}
                inputProps={{ min: 0 }}
              />
            </Grid>

            {/* その他設定 */}
            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom sx={{ mt: 2 }}>
                その他設定
              </Typography>
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="表示順序"
                type="number"
                value={formData.display_order}
                onChange={(e) => handleChange('display_order', parseInt(e.target.value) || 0)}
                inputProps={{ min: 0 }}
              />
            </Grid>

            <Grid item xs={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.is_active}
                    onChange={(e) => handleChange('is_active', e.target.checked)}
                  />
                }
                label="有効"
              />
            </Grid>
          </Grid>

          {/* プレビュー */}
          <Box sx={{ mt: 3, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
            <Typography variant="h6" gutterBottom>
              プレビュー
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>ミッション名:</strong> {formData.name || '（未入力）'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>説明:</strong> {formData.description || '（未入力）'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>タイプ:</strong> {getMissionTypeLabel(formData.mission_type)}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>目標:</strong> {getTargetTypeLabel(formData.target_type)} {formData.target_count}個
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>報酬:</strong> {formData.reward_gold}G + {formData.reward_exp}経験値
            </Typography>
          </Box>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button 
          onClick={handleSubmit} 
          variant="contained" 
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={16} /> : undefined}
        >
          {template ? '更新' : '作成'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}
