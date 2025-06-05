import React, { useState, useEffect } from 'react';
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
  Grid,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';
import {
  useGetAdventurersQuery,
  useDeleteAdventurerMutation,
} from '../services/api';
import type { AdventurerMaster } from '../types';
import { AdventurerCreateDialog } from '../components/AdventurerCreateDialog';
import { AdventurerEditDialog } from '../components/AdventurerEditDialog';

const AdventurerList: React.FC = () => {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [professionFilter, setProfessionFilter] = useState('');
  const [activeFilter, setActiveFilter] = useState('');
  const [selectedAdventurer, setSelectedAdventurer] = useState<AdventurerMaster | null>(null);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  // API呼び出し
  const {
    data: adventurersResponse,
    error,
    isLoading,
    refetch,
  } = useGetAdventurersQuery({
    page: page + 1,
    limit: rowsPerPage,
    search: searchTerm || undefined,
    profession: professionFilter || undefined,
    is_active: activeFilter === 'active' ? true : activeFilter === 'inactive' ? false : undefined,
  });

  const [deleteAdventurer] = useDeleteAdventurerMutation();

  const adventurers = adventurersResponse?.adventurers || [];
  const total = adventurersResponse?.total || 0;

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleEdit = (adventurer: AdventurerMaster) => {
    setSelectedAdventurer(adventurer);
    setEditDialogOpen(true);
  };

  const handleDelete = (adventurer: AdventurerMaster) => {
    setSelectedAdventurer(adventurer);
    setDeleteDialogOpen(true);
  };

  const handleCreate = () => {
    setSelectedAdventurer(null);
    setCreateDialogOpen(true);
  };

  const handleCloseCreateDialog = () => {
    setCreateDialogOpen(false);
    setSelectedAdventurer(null);
  };

  const handleCloseEditDialog = () => {
    setEditDialogOpen(false);
    setSelectedAdventurer(null);
  };

  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedAdventurer(null);
  };

  const handleConfirmDelete = async () => {
    if (selectedAdventurer) {
      try {
        await deleteAdventurer(selectedAdventurer.id).unwrap();
        refetch();
        handleCloseDeleteDialog();
      } catch (error) {
        console.error('削除に失敗しました:', error);
      }
    }
  };

  const handleRefresh = () => {
    refetch();
  };

  const getProfessionName = (profession: string) => {
    const professionMap: { [key: string]: string } = {
      warrior: '戦士',
      archer: '弓使い',
      mage: '魔法使い',
      rogue: '盗賊',
      paladin: '聖騎士',
    };
    return professionMap[profession] || profession;
  };

  const getPersonalityName = (personality: string) => {
    const personalityMap: { [key: string]: string } = {
      generous: '気前が良い',
      normal: '普通',
      stingy: 'けち',
      wealthy: '裕福',
      poor: '貧乏',
    };
    return personalityMap[personality] || personality;
  };

  const getUrgencyName = (urgency: number) => {
    const urgencyMap: { [key: number]: string } = {
      1: 'のんびり',
      2: '余裕',
      3: '普通',
      4: '緊急',
      5: '超緊急',
    };
    return urgencyMap[urgency] || '不明';
  };

  if (error) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          データの取得に失敗しました。サーバーが起動していることを確認してください。
        </Alert>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        冒険者マスター管理
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
              <InputLabel>職業</InputLabel>
              <Select
                value={professionFilter}
                onChange={(e) => setProfessionFilter(e.target.value)}
                label="職業"
              >
                <MenuItem value="">すべて</MenuItem>
                <MenuItem value="warrior">戦士</MenuItem>
                <MenuItem value="archer">弓使い</MenuItem>
                <MenuItem value="mage">魔法使い</MenuItem>
                <MenuItem value="rogue">盗賊</MenuItem>
                <MenuItem value="paladin">聖騎士</MenuItem>
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
            <IconButton onClick={handleRefresh}>
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
              <TableCell>ID</TableCell>
              <TableCell>名前</TableCell>
              <TableCell>職業</TableCell>
              <TableCell>レベル</TableCell>
              <TableCell>性格</TableCell>
              <TableCell>信頼度</TableCell>
              <TableCell>予算範囲</TableCell>
              <TableCell>緊急度</TableCell>
              <TableCell>状態</TableCell>
              <TableCell>操作</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {isLoading ? (
              <TableRow>
                <TableCell colSpan={10} align="center">
                  <CircularProgress />
                </TableCell>
              </TableRow>
            ) : adventurers.length === 0 ? (
              <TableRow>
                <TableCell colSpan={10} align="center">
                  <Typography color="text.secondary">
                    データがありません
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              adventurers.map((adventurer: any) => (
                <TableRow key={adventurer.id} hover>
                  <TableCell>{adventurer.id}</TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="bold">
                      {adventurer.name}
                    </Typography>
                  </TableCell>
                  <TableCell>{getProfessionName(adventurer.profession)}</TableCell>
                  <TableCell>{adventurer.level}</TableCell>
                  <TableCell>{getPersonalityName(adventurer.personality)}</TableCell>
                  <TableCell>{adventurer.trust_level}</TableCell>
                  <TableCell>
                    {adventurer.budget_min.toLocaleString()}G - {adventurer.budget_max.toLocaleString()}G
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={getUrgencyName(adventurer.urgency_tendency)}
                      size="small"
                      color={adventurer.urgency_tendency >= 4 ? 'error' : 
                             adventurer.urgency_tendency >= 3 ? 'warning' : 'success'}
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={adventurer.is_active ? '有効' : '無効'}
                      size="small"
                      color={adventurer.is_active ? 'success' : 'default'}
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton
                      size="small"
                      onClick={() => handleEdit(adventurer)}
                      color="primary"
                    >
                      <EditIcon />
                    </IconButton>
                    <IconButton
                      size="small"
                      onClick={() => handleDelete(adventurer)}
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
          count={adventurers.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </TableContainer>

      {/* 削除確認ダイアログ */}
      <Dialog open={deleteDialogOpen} onClose={handleCloseDeleteDialog}>
        <DialogTitle>冒険者の削除</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            この操作は取り消せません。
          </Alert>
          <Typography>
            冒険者「{selectedAdventurer?.name}」を削除しますか？
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog}>キャンセル</Button>
          <Button onClick={handleConfirmDelete} color="error" variant="contained">
            削除
          </Button>
        </DialogActions>
      </Dialog>

      {/* 新規作成ダイアログ */}
      <AdventurerCreateDialog
        open={createDialogOpen}
        onClose={handleCloseCreateDialog}
        onSuccess={() => {
          refetch();
          handleCloseCreateDialog();
        }}
      />

      {/* 編集ダイアログ */}
      <AdventurerEditDialog
        open={editDialogOpen}
        adventurer={selectedAdventurer}
        onClose={handleCloseEditDialog}
        onSuccess={() => {
          refetch();
          handleCloseEditDialog();
        }}
      />
    </Box>
  );
};

export default AdventurerList;
