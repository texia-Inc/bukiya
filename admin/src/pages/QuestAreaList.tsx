import React, { useState } from 'react';
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
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  CircularProgress,
  Avatar,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Refresh as RefreshIcon,
  DragHandle as OrderIcon,
} from '@mui/icons-material';

// モックデータ（後でAPIに置き換え）
const mockQuestAreas = [
  {
    id: 1,
    name: '初心者の森',
    area_type: 'forest',
    difficulty: 1,
    required_level: 1,
    duration_minutes: 30,
    image_url: null,
    background_color: '#4CAF50',
    description: '冒険者が最初に訪れる安全な森林エリア',
    unlock_condition: null,
    is_active: true,
    display_order: 1,
    created_at: '2025-06-01T10:00:00Z',
    updated_at: '2025-06-01T10:00:00Z',
  },
  {
    id: 2,
    name: '暗闇の洞窟',
    area_type: 'cave',
    difficulty: 3,
    required_level: 10,
    duration_minutes: 60,
    image_url: null,
    background_color: '#795548',
    description: '危険なモンスターが潜む洞窟',
    unlock_condition: '{"completed_areas": [1]}',
    is_active: true,
    display_order: 2,
    created_at: '2025-06-01T11:00:00Z',
    updated_at: '2025-06-01T11:00:00Z',
  },
  {
    id: 3,
    name: '竜の山',
    area_type: 'mountain',
    difficulty: 5,
    required_level: 30,
    duration_minutes: 120,
    image_url: null,
    background_color: '#FF5722',
    description: '伝説のドラゴンが住む危険な山岳地帯',
    unlock_condition: '{"completed_areas": [1, 2], "min_weapon_level": 20}',
    is_active: false,
    display_order: 3,
    created_at: '2025-06-01T12:00:00Z',
    updated_at: '2025-06-02T09:00:00Z',
  },
];

interface QuestArea {
  id: number;
  name: string;
  area_type: string;
  difficulty: number;
  required_level: number;
  duration_minutes: number;
  image_url: string | null;
  background_color: string;
  description: string | null;
  unlock_condition: string | null;
  is_active: boolean;
  display_order: number;
  created_at: string;
  updated_at: string;
}

const QuestAreaList: React.FC = () => {
  const [questAreas, setQuestAreas] = useState<QuestArea[]>(mockQuestAreas);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [activeFilter, setActiveFilter] = useState('');
  const [selectedQuestArea, setSelectedQuestArea] = useState<QuestArea | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  // フィルタリング
  const filteredQuestAreas = questAreas.filter((area) => {
    const matchesSearch = area.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = !typeFilter || area.area_type === typeFilter;
    const matchesActive = activeFilter === '' || 
      (activeFilter === 'active' && area.is_active) ||
      (activeFilter === 'inactive' && !area.is_active);
    
    return matchesSearch && matchesType && matchesActive;
  });

  // 表示順序でソート
  const sortedQuestAreas = filteredQuestAreas.sort((a, b) => a.display_order - b.display_order);

  // ページネーション
  const paginatedQuestAreas = sortedQuestAreas.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleEdit = (area: QuestArea) => {
    setSelectedQuestArea(area);
    setDialogOpen(true);
  };

  const handleDelete = (area: QuestArea) => {
    setSelectedQuestArea(area);
    setDeleteDialogOpen(true);
  };

  const handleCreate = () => {
    setSelectedQuestArea(null);
    setDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
    setSelectedQuestArea(null);
  };

  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedQuestArea(null);
  };

  const handleConfirmDelete = () => {
    if (selectedQuestArea) {
      setQuestAreas(prev => prev.filter(a => a.id !== selectedQuestArea.id));
      handleCloseDeleteDialog();
    }
  };

  const getAreaTypeName = (type: string) => {
    const typeMap: { [key: string]: string } = {
      forest: '森林',
      cave: '洞窟',
      mountain: '山岳',
      ruins: '遺跡',
      desert: '砂漠',
      ocean: '海洋',
      sky: '空中',
    };
    return typeMap[type] || type;
  };

  const getDifficultyName = (difficulty: number) => {
    const difficultyMap: { [key: number]: string } = {
      1: '初級',
      2: '中級',
      3: '上級',
      4: '超級',
      5: '最高級',
    };
    return difficultyMap[difficulty] || `Lv.${difficulty}`;
  };

  const getDifficultyColor = (difficulty: number) => {
    const colorMap: { [key: number]: 'success' | 'info' | 'warning' | 'error' | 'default' } = {
      1: 'success',
      2: 'info',
      3: 'warning',
      4: 'error',
      5: 'error',
    };
    return colorMap[difficulty] || 'default';
  };

  const formatDuration = (minutes: number) => {
    if (minutes < 60) {
      return `${minutes}分`;
    }
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return remainingMinutes > 0 ? `${hours}時間${remainingMinutes}分` : `${hours}時間`;
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        クエストエリア管理
      </Typography>

      {/* フィルター・検索エリア */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, alignItems: 'center' }}>
          <Box sx={{ minWidth: 200, flex: 1 }}>
            <TextField
              fullWidth
              label="検索"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: <SearchIcon sx={{ mr: 1, color: 'text.secondary' }} />,
              }}
            />
          </Box>
          <Box sx={{ minWidth: 120 }}>
            <FormControl fullWidth>
              <InputLabel>タイプ</InputLabel>
              <Select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                label="タイプ"
              >
                <MenuItem value="">すべて</MenuItem>
                <MenuItem value="forest">森林</MenuItem>
                <MenuItem value="cave">洞窟</MenuItem>
                <MenuItem value="mountain">山岳</MenuItem>
                <MenuItem value="ruins">遺跡</MenuItem>
                <MenuItem value="desert">砂漠</MenuItem>
                <MenuItem value="ocean">海洋</MenuItem>
                <MenuItem value="sky">空中</MenuItem>
              </Select>
            </FormControl>
          </Box>
          <Box sx={{ minWidth: 120 }}>
            <FormControl fullWidth>
              <InputLabel>状態</InputLabel>
              <Select
                value={activeFilter}
                onChange={(e) => setActiveFilter(e.target.value)}
                label="状態"
              >
                <MenuItem value="">すべて</MenuItem>
                <MenuItem value="active">有効</MenuItem>
                <MenuItem value="inactive">無効</MenuItem>
              </Select>
            </FormControl>
          </Box>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              variant="contained"
              startIcon={<AddIcon />}
              onClick={handleCreate}
            >
              新規作成
            </Button>
            <IconButton onClick={() => setLoading(true)}>
              <RefreshIcon />
            </IconButton>
          </Box>
        </Box>
      </Paper>

      {/* テーブル */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>順序</TableCell>
              <TableCell>エリア</TableCell>
              <TableCell>タイプ</TableCell>
              <TableCell>難易度</TableCell>
              <TableCell>必要レベル</TableCell>
              <TableCell>所要時間</TableCell>
              <TableCell>解放条件</TableCell>
              <TableCell>状態</TableCell>
              <TableCell>操作</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={9} align="center">
                  <CircularProgress />
                </TableCell>
              </TableRow>
            ) : (
              paginatedQuestAreas.map((area) => (
                <TableRow key={area.id} hover>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <OrderIcon color="action" />
                      <Typography variant="body2">{area.display_order}</Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      <Avatar
                        sx={{
                          bgcolor: area.background_color,
                          width: 32,
                          height: 32,
                          fontSize: '0.875rem',
                        }}
                      >
                        {area.name.charAt(0)}
                      </Avatar>
                      <Box>
                        <Typography variant="body2" fontWeight="bold">
                          {area.name}
                        </Typography>
                        {area.description && (
                          <Typography variant="caption" color="text.secondary">
                            {area.description}
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  </TableCell>
                  <TableCell>{getAreaTypeName(area.area_type)}</TableCell>
                  <TableCell>
                    <Chip
                      label={getDifficultyName(area.difficulty)}
                      size="small"
                      color={getDifficultyColor(area.difficulty)}
                    />
                  </TableCell>
                  <TableCell>Lv.{area.required_level}</TableCell>
                  <TableCell>{formatDuration(area.duration_minutes)}</TableCell>
                  <TableCell>
                    {area.unlock_condition ? (
                      <Chip label="条件あり" size="small" color="warning" />
                    ) : (
                      <Chip label="なし" size="small" color="success" />
                    )}
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={area.is_active ? '有効' : '無効'}
                      size="small"
                      color={area.is_active ? 'success' : 'default'}
                    />
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', gap: 0.5 }}>
                      <IconButton
                        size="small"
                        onClick={() => handleEdit(area)}
                        color="primary"
                      >
                        <EditIcon />
                      </IconButton>
                      <IconButton
                        size="small"
                        onClick={() => handleDelete(area)}
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
          count={sortedQuestAreas.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </TableContainer>

      {/* 削除確認ダイアログ */}
      <Dialog open={deleteDialogOpen} onClose={handleCloseDeleteDialog}>
        <DialogTitle>クエストエリアの削除</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            この操作は取り消せません。
          </Alert>
          <Typography>
            クエストエリア「{selectedQuestArea?.name}」を削除しますか？
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog}>キャンセル</Button>
          <Button onClick={handleConfirmDelete} color="error" variant="contained">
            削除
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default QuestAreaList;
