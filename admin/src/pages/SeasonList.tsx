import React, { useState, useMemo } from 'react';
import {
  Container,
  Typography,
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  TextField,
  MenuItem,
  Alert,
  CircularProgress,
  Chip,
  IconButton,
  Tooltip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  TablePagination,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';
import {
  useGetSeasonsQuery,
  useDeleteSeasonMutation,
} from '../services/api';
import type { Season } from '../types';
import { SeasonCreateDialog } from '../components/SeasonCreateDialog';
import { SeasonEditDialog } from '../components/SeasonEditDialog';

export const SeasonList: React.FC = () => {
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [selectedSeason, setSelectedSeason] = useState<Season | null>(null);

  const {
    data: seasonsResponse,
    error,
    isLoading,
    refetch,
  } = useGetSeasonsQuery({
    page,
    limit: pageSize,
    search: searchTerm || undefined,
    is_active: statusFilter === 'all' ? undefined : statusFilter === 'active',
  });

  const [deleteSeason] = useDeleteSeasonMutation();

  const seasons = seasonsResponse?.data || [];
  const totalCount = seasonsResponse?.pagination?.total || 0;

  const handleEdit = (season: Season) => {
    setSelectedSeason(season);
    setEditDialogOpen(true);
  };

  const handleDelete = async (season: Season) => {
    if (window.confirm(`シーズン「${season.name}」を削除しますか？`)) {
      try {
        await deleteSeason(season.id).unwrap();
        refetch();
      } catch (error) {
        console.error('削除に失敗しました:', error);
        alert('削除に失敗しました。');
      }
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ja-JP');
  };

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage + 1);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPageSize(parseInt(event.target.value, 10));
    setPage(1);
  };

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          シーズン管理
        </Typography>
        <Box sx={{ display: 'flex', gap: 2 }}>
          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={() => refetch()}
          >
            更新
          </Button>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => setCreateDialogOpen(true)}
          >
            新規作成
          </Button>
        </Box>
      </Box>

      {/* フィルター */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                label="シーズン名で検索"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                size="small"
              />
            </Grid>
            <Grid item xs={12} md={3}>
              <TextField
                fullWidth
                select
                label="ステータス"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as any)}
                size="small"
              >
                <MenuItem value="all">すべて</MenuItem>
                <MenuItem value="active">有効</MenuItem>
                <MenuItem value="inactive">無効</MenuItem>
              </TextField>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* エラー表示 */}
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          データの取得に失敗しました。
        </Alert>
      )}

      {/* テーブル */}
      <Card>
        <CardContent>
          {isLoading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : (
            <>
              <TableContainer component={Paper}>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell align="center">表示順</TableCell>
                      <TableCell>シーズン名</TableCell>
                      <TableCell>説明</TableCell>
                      <TableCell>開始日</TableCell>
                      <TableCell>終了日</TableCell>
                      <TableCell align="center">ステータス</TableCell>
                      <TableCell>作成日</TableCell>
                      <TableCell align="center">操作</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {seasons.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={8} align="center">
                          <Typography color="text.secondary">
                            シーズンが登録されていません
                          </Typography>
                        </TableCell>
                      </TableRow>
                    ) : (
                      seasons.map((season) => (
                        <TableRow key={season.id} hover>
                          <TableCell align="center">{season.display_order}</TableCell>
                          <TableCell>{season.name}</TableCell>
                          <TableCell>
                            <Tooltip title={season.description || ''} arrow>
                              <Typography variant="body2" noWrap sx={{ maxWidth: 200 }}>
                                {season.description || '-'}
                              </Typography>
                            </Tooltip>
                          </TableCell>
                          <TableCell>{formatDate(season.start_date)}</TableCell>
                          <TableCell>
                            {season.end_date ? formatDate(season.end_date) : '未設定'}
                          </TableCell>
                          <TableCell align="center">
                            <Chip
                              label={season.is_active ? '有効' : '無効'}
                              size="small"
                              color={season.is_active ? 'success' : 'default'}
                            />
                          </TableCell>
                          <TableCell>{formatDate(season.created_at)}</TableCell>
                          <TableCell align="center">
                            <Box sx={{ display: 'flex', gap: 0.5 }}>
                              <IconButton
                                size="small"
                                onClick={() => handleEdit(season)}
                                color="primary"
                              >
                                <EditIcon />
                              </IconButton>
                              <IconButton
                                size="small"
                                onClick={() => handleDelete(season)}
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
              </TableContainer>
              
              <TablePagination
                component="div"
                count={totalCount}
                page={page - 1}
                onPageChange={handleChangePage}
                rowsPerPage={pageSize}
                onRowsPerPageChange={handleChangeRowsPerPage}
                rowsPerPageOptions={[10, 20, 50, 100]}
                labelRowsPerPage="行数:"
                labelDisplayedRows={({ from, to, count }) =>
                  `${from}-${to} / ${count !== -1 ? count : `${to}以上`}`
                }
              />
            </>
          )}
        </CardContent>
      </Card>

      {/* 作成ダイアログ */}
      <SeasonCreateDialog
        open={createDialogOpen}
        onClose={() => setCreateDialogOpen(false)}
        onSuccess={() => {
          refetch();
          setCreateDialogOpen(false);
        }}
      />

      {/* 編集ダイアログ */}
      <SeasonEditDialog
        open={editDialogOpen}
        season={selectedSeason}
        onClose={() => {
          setEditDialogOpen(false);
          setSelectedSeason(null);
        }}
        onSuccess={() => {
          refetch();
          setEditDialogOpen(false);
          setSelectedSeason(null);
        }}
      />
    </Container>
  );
};