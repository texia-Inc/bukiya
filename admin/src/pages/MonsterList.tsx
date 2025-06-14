import React, { useState } from 'react';
import {
  Box,
  Paper,
  Typography,
  Button,
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
  Tooltip,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Refresh as RefreshIcon,
  Inventory as DropIcon,
} from '@mui/icons-material';
import {
  useGetMonstersQuery,
  useDeleteMonsterMutation,
} from '../services/api';
import type { MonsterMaster } from '../types';
import { MonsterCreateDialog } from '../components/MonsterCreateDialog';
import { MonsterEditDialog } from '../components/MonsterEditDialog';
import { MonsterDropTableDialog } from '../components/MonsterDropTableDialog';
import SortableTable from '../components/SortableTable';
import type { SortableColumn } from '../components/SortableTable';

const MonsterList: React.FC = () => {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [activeFilter, setActiveFilter] = useState('');
  const [selectedMonster, setSelectedMonster] = useState<MonsterMaster | null>(null);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [dropDialogOpen, setDropDialogOpen] = useState(false);

  // API呼び出し
  const {
    data: monstersResponse,
    error,
    isLoading,
    refetch,
  } = useGetMonstersQuery({
    page: page + 1,
    limit: rowsPerPage,
    search: searchTerm || undefined,
    monster_type: typeFilter || undefined,
    is_active: activeFilter === 'active' ? true : activeFilter === 'inactive' ? false : undefined,
  });

  const [deleteMonster] = useDeleteMonsterMutation();

  const monsters = monstersResponse?.data || [];
  const total = monstersResponse?.pagination?.total || 0;

  // テーブルのカラム定義
  const monsterColumns: SortableColumn[] = [
    {
      id: 'id',
      label: 'ID',
      numeric: true,
      align: 'left',
    },
    {
      id: 'name',
      label: '名前',
      renderCell: (monster) => (
        <Typography variant="body2" fontWeight="bold">
          {monster.name}
        </Typography>
      ),
    },
    {
      id: 'monster_type',
      label: 'タイプ',
      renderCell: (monster) => getMonsterTypeName(monster.monster_type),
    },
    {
      id: 'level',
      label: 'レベル',
      numeric: true,
    },
    {
      id: 'hp',
      label: 'HP',
      numeric: true,
      renderCell: (monster) => monster.hp.toLocaleString(),
    },
    {
      id: 'attack',
      label: '攻撃力',
      numeric: true,
    },
    {
      id: 'defense',
      label: '防御力',
      numeric: true,
    },
    {
      id: 'element',
      label: '属性',
      sortable: false,
      renderCell: (monster) => (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
          <Typography variant="caption">
            属性: {getElementName(monster.element)}
          </Typography>
          <Typography variant="caption">
            弱点: {getElementName(monster.weakness)}
          </Typography>
        </Box>
      ),
    },
    {
      id: 'spawn_areas',
      label: '出現エリア',
      sortable: false,
      renderCell: (monster) => (
        <Typography variant="caption">
          {getAreaNames(monster.spawn_areas)}
        </Typography>
      ),
    },
    {
      id: 'base_gold_reward',
      label: '報酬',
      numeric: true,
      sortable: false,
      renderCell: (monster) => (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
          <Typography variant="caption">
            {monster.base_gold_reward}G
          </Typography>
          <Typography variant="caption">
            EXP {monster.experience_reward}
          </Typography>
        </Box>
      ),
    },
    {
      id: 'is_active',
      label: '状態',
      sortable: false,
      renderCell: (monster) => (
        <Chip
          label={monster.is_active ? '有効' : '無効'}
          size="small"
          color={monster.is_active ? 'success' : 'default'}
        />
      ),
    },
    {
      id: 'actions',
      label: '操作',
      sortable: false,
      renderCell: (monster) => (
        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap', alignItems: 'center' }}>
          <Tooltip title="編集">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleEdit(monster);
              }}
              color="primary"
            >
              <EditIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="ドロップテーブル管理">
            <Button
              size="small"
              variant="outlined"
              color="secondary"
              startIcon={<DropIcon />}
              onClick={(e) => {
                e.stopPropagation();
                handleDropTable(monster);
              }}
              sx={{ minWidth: 'auto', fontSize: '0.75rem' }}
            >
              ドロップ
            </Button>
          </Tooltip>
          <Tooltip title="削除">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleDelete(monster);
              }}
              color="error"
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleEdit = (monster: MonsterMaster) => {
    setSelectedMonster(monster);
    setEditDialogOpen(true);
  };

  const handleDelete = (monster: MonsterMaster) => {
    setSelectedMonster(monster);
    setDeleteDialogOpen(true);
  };

  const handleDropTable = (monster: MonsterMaster) => {
    setSelectedMonster(monster);
    setDropDialogOpen(true);
  };

  const handleCreate = () => {
    setSelectedMonster(null);
    setCreateDialogOpen(true);
  };

  const handleCloseCreateDialog = () => {
    setCreateDialogOpen(false);
    setSelectedMonster(null);
  };

  const handleCloseEditDialog = () => {
    setEditDialogOpen(false);
    setSelectedMonster(null);
  };

  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedMonster(null);
  };

  const handleCloseDropDialog = () => {
    setDropDialogOpen(false);
    setSelectedMonster(null);
  };

  const handleConfirmDelete = async () => {
    if (selectedMonster) {
      try {
        await deleteMonster(selectedMonster.id).unwrap();
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

  const getMonsterTypeName = (type: string) => {
    const typeMap: { [key: string]: string } = {
      beast: '野獣',
      undead: 'アンデッド',
      dragon: 'ドラゴン',
      elemental: 'エレメンタル',
      demon: '悪魔',
      humanoid: '人型',
    };
    return typeMap[type] || type;
  };

  const getElementName = (element: string | null) => {
    if (!element || element === 'none') return '-';
    const elementMap: { [key: string]: string } = {
      fire: '火',
      ice: '氷',
      thunder: '雷',
      earth: '土',
      wind: '風',
      light: '光',
      dark: '闇',
    };
    return elementMap[element] || element;
  };

  const getAreaNames = (areas: string | null | undefined) => {
    if (!areas) {
      return '未設定';
    }
    const areaMap: { [key: string]: string } = {
      forest: '森林',
      cave: '洞窟',
      mountain: '山岳',
      ruins: '遺跡',
      desert: '砂漠',
    };
    return areas.split(',').map(area => areaMap[area.trim()] || area.trim()).join(', ');
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
        モンスターマスター管理
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
                <MenuItem value="beast">野獣</MenuItem>
                <MenuItem value="undead">アンデッド</MenuItem>
                <MenuItem value="dragon">ドラゴン</MenuItem>
                <MenuItem value="elemental">エレメンタル</MenuItem>
                <MenuItem value="demon">悪魔</MenuItem>
                <MenuItem value="humanoid">人型</MenuItem>
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
      <Paper>
        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <CircularProgress />
          </Box>
        ) : monsters.length === 0 ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <Typography color="text.secondary">
              データがありません
            </Typography>
          </Box>
        ) : (
          <SortableTable
            columns={monsterColumns}
            data={monsters}
            defaultSortBy="id"
            defaultSortOrder="asc"
          />
        )}
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={total}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>

      {/* 削除確認ダイアログ */}
      <Dialog open={deleteDialogOpen} onClose={handleCloseDeleteDialog}>
        <DialogTitle>モンスターの削除</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            この操作は取り消せません。関連するドロップテーブルも削除されます。
          </Alert>
          <Typography>
            モンスター「{selectedMonster?.name}」を削除しますか？
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
      <MonsterCreateDialog
        open={createDialogOpen}
        onClose={handleCloseCreateDialog}
        onSuccess={() => {
          refetch();
          handleCloseCreateDialog();
        }}
      />

      {/* 編集ダイアログ */}
      <MonsterEditDialog
        open={editDialogOpen}
        monster={selectedMonster}
        onClose={handleCloseEditDialog}
        onSuccess={() => {
          refetch();
          handleCloseEditDialog();
        }}
      />

      {/* ドロップテーブル管理ダイアログ */}
      <MonsterDropTableDialog
        open={dropDialogOpen}
        monster={selectedMonster}
        onClose={handleCloseDropDialog}
      />
    </Box>
  );
};

export default MonsterList;
