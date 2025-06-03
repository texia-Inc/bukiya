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
  Refresh as RefreshIcon,
} from '@mui/icons-material'
import {
  useGetMissionTemplatesQuery,
  useDeleteMissionTemplateMutation,
} from '../services/api'
import type { MissionTemplate } from '../types'
import { MissionTemplateDialog } from '../components/MissionTemplateDialog'
import { MissionDeleteDialog } from '../components/MissionDeleteDialog'

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

  // API呼び出し
  const {
    data: templatesResponse,
    error,
    isLoading,
    refetch,
  } = useGetMissionTemplatesQuery({
    page: page + 1,
    limit: rowsPerPage,
    search: searchTerm || undefined,
    mission_type: (missionTypeFilter as 'daily' | 'weekly' | 'achievement') || undefined,
    is_active: isActiveFilter === 'true' ? true : isActiveFilter === 'false' ? false : undefined,
  })

  const [deleteMissionTemplate] = useDeleteMissionTemplateMutation()

  const templates = templatesResponse?.data || []
  const total = templates.length

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

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false)
    setSelectedTemplate(null)
  }

  const handleConfirmDelete = async () => {
    if (selectedTemplate) {
      try {
        await deleteMissionTemplate(selectedTemplate.id).unwrap()
        refetch()
        handleDeleteDialogClose()
      } catch (error) {
        console.error('削除に失敗しました:', error)
      }
    }
  }

  const handleRefresh = () => {
    refetch()
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
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          データの取得に失敗しました。サーバーが起動していることを確認してください。
        </Alert>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={1}>
          <MissionIcon color="primary" />
          <Typography variant="h4" component="h1">
            ミッションテンプレート管理
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => setCreateDialogOpen(true)}
          >
            新規作成
          </Button>
          <IconButton onClick={handleRefresh}>
            <RefreshIcon />
          </IconButton>
        </Box>
      </Box>

      {/* フィルター */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
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
            ) : templates.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center">
                  <Typography color="text.secondary">
                    データがありません
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              templates.map((template: MissionTemplate) => (
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
                    <Box sx={{ display: 'flex', gap: 0.5 }}>
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
                    </Box>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={templates.length}
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
        onClose={handleDeleteDialogClose}
        template={selectedTemplate}
        onConfirm={handleConfirmDelete}
        isLoading={false}
      />
    </Box>
  )
}

export default MissionTemplateList
