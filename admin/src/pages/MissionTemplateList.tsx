import React, { useState } from 'react'
import {
  Box,
  Paper,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Chip,
  IconButton,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Stack,
  Alert,
  CircularProgress,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Assignment as MissionIcon,
} from '@mui/icons-material'
import { MissionTemplateDialog } from '../components/MissionTemplateDialog'
import { MissionDeleteDialog } from '../components/MissionDeleteDialog'

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

const MissionTemplateList: React.FC = () => {
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(10)
  const [searchTerm, setSearchTerm] = useState('')
  const [missionTypeFilter, setMissionTypeFilter] = useState<string>('')
  const [isActiveFilter, setIsActiveFilter] = useState<string>('')
  const [createDialogOpen, setCreateDialogOpen] = useState(false)
  const [editDialogOpen, setEditDialogOpen] = useState(false)
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [selectedTemplate, setSelectedTemplate] = useState<MissionTemplate | null>(null)

  // モックデータ（APIが利用可能になるまで）
  const mockTemplates: MissionTemplate[] = [
    {
      id: 1,
      name: '武器を3個作成する',
      description: 'デイリーミッション：武器を3個作成してください',
      mission_type: 'daily',
      target_type: 'craft_weapon',
      target_count: 3,
      target_conditions: null,
      reward_gold: 500,
      reward_exp: 50,
      reward_items: null,
      is_active: true,
      reset_schedule: 'daily',
      required_level: 1,
      display_order: 1,
      created_at: '2025-06-03T00:00:00Z',
      updated_at: '2025-06-03T00:00:00Z',
    },
    {
      id: 2,
      name: '冒険者に武器を5個販売する',
      description: 'デイリーミッション：冒険者に武器を5個販売してください',
      mission_type: 'daily',
      target_type: 'sell_weapon',
      target_count: 5,
      target_conditions: null,
      reward_gold: 1000,
      reward_exp: 100,
      reward_items: null,
      is_active: true,
      reset_schedule: 'daily',
      required_level: 1,
      display_order: 2,
      created_at: '2025-06-03T00:00:00Z',
      updated_at: '2025-06-03T00:00:00Z',
    },
    {
      id: 3,
      name: 'レア武器を10個作成する',
      description: 'ウィークリーミッション：レア武器を10個作成してください',
      mission_type: 'weekly',
      target_type: 'craft_weapon',
      target_count: 10,
      target_conditions: { rarity: 'rare' },
      reward_gold: 5000,
      reward_exp: 500,
      reward_items: { rare_materials: 3 },
      is_active: true,
      reset_schedule: 'weekly',
      required_level: 5,
      display_order: 1,
      created_at: '2025-06-03T00:00:00Z',
      updated_at: '2025-06-03T00:00:00Z',
    },
    {
      id: 4,
      name: '武器マスター',
      description: 'アチーブメント：累計武器作成数1000個を達成してください',
      mission_type: 'achievement',
      target_type: 'craft_weapon',
      target_count: 1000,
      target_conditions: null,
      reward_gold: 50000,
      reward_exp: 5000,
      reward_items: { title: 'weapon_master', bonus: 'craft_speed_10' },
      is_active: true,
      reset_schedule: null,
      required_level: 1,
      display_order: 1,
      created_at: '2025-06-03T00:00:00Z',
      updated_at: '2025-06-03T00:00:00Z',
    },
  ]

  const templates = mockTemplates
  const isLoading = false
  const error = null

  // フィルタリング
  const filteredTemplates = templates.filter((template: MissionTemplate) =>
    template.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    template.description.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // ページネーション
  const paginatedTemplates = filteredTemplates.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  )

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage)
  }

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10))
    setPage(0)
  }

  const handleEdit = (template: MissionTemplate) => {
    setSelectedTemplate(template)
    setEditDialogOpen(true)
  }

  const handleDelete = (template: MissionTemplate) => {
    setSelectedTemplate(template)
    setDeleteDialogOpen(true)
  }

  const handleDialogClose = () => {
    setCreateDialogOpen(false)
    setEditDialogOpen(false)
    setSelectedTemplate(null)
  }

  const getMissionTypeLabel = (type: string) => {
    switch (type) {
      case 'daily': return 'デイリー'
      case 'weekly': return 'ウィークリー'
      case 'achievement': return 'アチーブメント'
      default: return type
    }
  }

  const getMissionTypeColor = (type: string) => {
    switch (type) {
      case 'daily': return 'primary'
      case 'weekly': return 'secondary'
      case 'achievement': return 'warning'
      default: return 'default'
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

  if (error) {
    return (
      <Alert severity="error">
        ミッションテンプレートの読み込みに失敗しました
      </Alert>
    )
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={1}>
          <MissionIcon color="primary" />
          <Typography variant="h4" component="h1">
            ミッションテンプレート管理
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => setCreateDialogOpen(true)}
        >
          新規作成
        </Button>
      </Box>

      {/* フィルター */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Stack direction="row" spacing={2} alignItems="center">
          <TextField
            label="検索"
            variant="outlined"
            size="small"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: <SearchIcon color="action" sx={{ mr: 1 }} />,
            }}
            sx={{ minWidth: 200 }}
          />
          
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>ミッションタイプ</InputLabel>
            <Select
              value={missionTypeFilter}
              label="ミッションタイプ"
              onChange={(e) => setMissionTypeFilter(e.target.value)}
            >
              <MenuItem value="">すべて</MenuItem>
              <MenuItem value="daily">デイリー</MenuItem>
              <MenuItem value="weekly">ウィークリー</MenuItem>
              <MenuItem value="achievement">アチーブメント</MenuItem>
            </Select>
          </FormControl>

          <FormControl size="small" sx={{ minWidth: 120 }}>
            <InputLabel>状態</InputLabel>
            <Select
              value={isActiveFilter}
              label="状態"
              onChange={(e) => setIsActiveFilter(e.target.value)}
            >
              <MenuItem value="">すべて</MenuItem>
              <MenuItem value="true">有効</MenuItem>
              <MenuItem value="false">無効</MenuItem>
            </Select>
          </FormControl>
        </Stack>
      </Paper>

      {/* テーブル */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>ミッション名</TableCell>
              <TableCell>タイプ</TableCell>
              <TableCell>目標</TableCell>
              <TableCell>報酬</TableCell>
              <TableCell>状態</TableCell>
              <TableCell>表示順序</TableCell>
              <TableCell>操作</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {isLoading ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  <CircularProgress />
                </TableCell>
              </TableRow>
            ) : paginatedTemplates.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  ミッションテンプレートが見つかりません
                </TableCell>
              </TableRow>
            ) : (
              paginatedTemplates.map((template: MissionTemplate) => (
                <TableRow key={template.id} hover>
                  <TableCell>{template.id}</TableCell>
                  <TableCell>
                    <Box>
                      <Typography variant="body2" fontWeight="bold">
                        {template.name}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {template.description}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={getMissionTypeLabel(template.mission_type)}
                      color={getMissionTypeColor(template.mission_type) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Box>
                      <Typography variant="body2">
                        {getTargetTypeLabel(template.target_type)}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        目標数: {template.target_count}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Box>
                      {template.reward_gold > 0 && (
                        <Typography variant="caption" display="block">
                          ゴールド: {template.reward_gold.toLocaleString()}G
                        </Typography>
                      )}
                      {template.reward_exp > 0 && (
                        <Typography variant="caption" display="block">
                          経験値: {template.reward_exp.toLocaleString()}
                        </Typography>
                      )}
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={template.is_active ? '有効' : '無効'}
                      color={template.is_active ? 'success' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{template.display_order}</TableCell>
                  <TableCell>
                    <IconButton
                      size="small"
                      onClick={() => handleEdit(template)}
                      color="primary"
                    >
                      <EditIcon />
                    </IconButton>
                    <IconButton
                      size="small"
                      onClick={() => handleDelete(template)}
                      color="error"
                    >
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={filteredTemplates.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          labelRowsPerPage="表示件数:"
          labelDisplayedRows={({ from, to, count }) =>
            `${from}-${to} / ${count !== -1 ? count : `more than ${to}`}`
          }
        />
      </TableContainer>

      {/* ダイアログ */}
      <MissionTemplateDialog
        open={createDialogOpen}
        onClose={handleDialogClose}
        template={null}
      />
      
      <MissionTemplateDialog
        open={editDialogOpen}
        onClose={handleDialogClose}
        template={selectedTemplate}
      />

      <MissionDeleteDialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
        template={selectedTemplate}
        onConfirm={() => {
          // TODO: API実装後に削除処理を追加
          console.log('Delete template:', selectedTemplate?.id)
          setDeleteDialogOpen(false)
          setSelectedTemplate(null)
        }}
        isLoading={false}
      />
    </Box>
  )
}

export default MissionTemplateList
