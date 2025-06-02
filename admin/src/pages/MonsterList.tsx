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
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Refresh as RefreshIcon,
  ViewList as DropIcon,
} from '@mui/icons-material';

// モックデータ（後でAPIに置き換え）
const mockMonsters = [
  {
    id: 1,
    name: 'ゴブリン',
    monster_type: 'beast',
    level: 5,
    hp: 100,
    attack: 30,
    defense: 10,
    element: 'none',
    weakness: 'fire',
    resistance: null,
    spawn_areas: 'forest',
    spawn_weight: 100,
    min_required_weapon_level: 0,
    base_gold_reward: 50,
    experience_reward: 25,
    is_active: true,
    created_at: '2025-06-01T10:00:00Z',
    updated_at: '2025-06-01T10:00:00Z',
  },
  {
    id: 2,
    name: 'オーク',
    monster_type: 'beast',
    level: 12,
    hp: 250,
    attack: 60,
    defense: 25,
    element: 'none',
    weakness: 'ice',
    resistance: 'fire',
    spawn_areas: 'forest,cave',
    spawn_weight: 80,
    min_required_weapon_level: 5,
    base_gold_reward: 120,
    experience_reward: 60,
    is_active: true,
    created_at: '2025-06-01T11:00:00Z',
    updated_at: '2025-06-01T11:00:00Z',
  },
  {
    id: 3,
    name: 'ドラゴン',
    monster_type: 'dragon',
    level: 50,
    hp: 2000,
    attack: 300,
    defense: 150,
    element: 'fire',
    weakness: 'ice',
    resistance: 'fire',
    spawn_areas: 'mountain',
    spawn_weight: 10,
    min_required_weapon_level: 30,
    base_gold_reward: 5000,
    experience_reward: 2500,
    is_active: false,
    created_at: '2025-06-01T12:00:00Z',
    updated_at: '2025-06-02T09:00:00Z',
  },
];

interface Monster {
  id: number;
  name: string;
  monster_type: string;
  level: number;
  hp: number;
  attack: number;
  defense: number;
  element: string | null;
  weakness: string | null;
  resistance: string | null;
  spawn_areas: string;
  spawn_weight: number;
  min_required_weapon_level: number;
  base_gold_reward: number;
  experience_reward: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

const MonsterList: React.FC = () => {
  const [monsters, setMonsters] = useState<Monster[]>(mockMonsters);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [activeFilter, setActiveFilter] = useState('');
  const [selectedMonster, setSelectedMonster] = useState<Monster | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [dropDialogOpen, setDropDialogOpen] = useState(false);

  // フィルタリング
  const filteredMonsters = monsters.filter((monster) => {
    const matchesSearch = monster.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = !typeFilter || monster.monster_type === typeFilter;
    const matchesActive = activeFilter === '' || 
      (activeFilter === 'active' && monster.is_active) ||
      (activeFilter === 'inactive' && !monster.is_active);
    
    return matchesSearch && matchesType && matchesActive;
  });

  // ページネーション
  const paginatedMonsters = filteredMonsters.slice(
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

  const handleEdit = (monster: Monster) => {
    setSelectedMonster(monster);
    setDialogOpen(true);
  };

  const handleDelete = (monster: Monster) => {
    setSelectedMonster(monster);
    setDeleteDialogOpen(true);
  };

  const handleDropTable = (monster: Monster) => {
    setSelectedMonster(monster);
    setDropDialogOpen(true);
  };

  const handleCreate = () => {
    setSelectedMonster(null);
    setDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
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

  const handleConfirmDelete = () => {
    if (selectedMonster) {
      setMonsters(prev => prev.filter(m => m.id !== selectedMonster.id));
      handleCloseDeleteDialog();
    }
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

  const getAreaNames = (areas: string) => {
    const areaMap: { [key: string]: string } = {
      forest: '森林',
      cave: '洞窟',
      mountain: '山岳',
      ruins: '遺跡',
      desert: '砂漠',
    };
    return areas.split(',').map(area => areaMap[area.trim()] || area.trim()).join(', ');
  };

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
              <TableCell>ID</TableCell>
              <TableCell>名前</TableCell>
              <TableCell>タイプ</TableCell>
              <TableCell>レベル</TableCell>
              <TableCell>HP</TableCell>
              <TableCell>攻撃力</TableCell>
              <TableCell>防御力</TableCell>
              <TableCell>属性</TableCell>
              <TableCell>出現エリア</TableCell>
              <TableCell>報酬</TableCell>
              <TableCell>状態</TableCell>
              <TableCell>操作</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={12} align="center">
                  <CircularProgress />
                </TableCell>
              </TableRow>
            ) : (
              paginatedMonsters.map((monster) => (
                <TableRow key={monster.id} hover>
                  <TableCell>{monster.id}</TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="bold">
                      {monster.name}
                    </Typography>
                  </TableCell>
                  <TableCell>{getMonsterTypeName(monster.monster_type)}</TableCell>
                  <TableCell>{monster.level}</TableCell>
                  <TableCell>{monster.hp.toLocaleString()}</TableCell>
                  <TableCell>{monster.attack}</TableCell>
                  <TableCell>{monster.defense}</TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                      <Typography variant="caption">
                        属性: {getElementName(monster.element)}
                      </Typography>
                      <Typography variant="caption">
                        弱点: {getElementName(monster.weakness)}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Typography variant="caption">
                      {getAreaNames(monster.spawn_areas)}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                      <Typography variant="caption">
                        {monster.base_gold_reward}G
                      </Typography>
                      <Typography variant="caption">
                        EXP {monster.experience_reward}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={monster.is_active ? '有効' : '無効'}
                      size="small"
                      color={monster.is_active ? 'success' : 'default'}
                    />
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', gap: 0.5 }}>
                      <IconButton
                        size="small"
                        onClick={() => handleEdit(monster)}
                        color="primary"
                      >
                        <EditIcon />
                      </IconButton>
                      <IconButton
                        size="small"
                        onClick={() => handleDropTable(monster)}
                        color="info"
                      >
                        <DropIcon />
                      </IconButton>
                      <IconButton
                        size="small"
                        onClick={() => handleDelete(monster)}
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
          count={filteredMonsters.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </TableContainer>

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

      {/* ドロップテーブル管理ダイアログ */}
      <Dialog open={dropDialogOpen} onClose={handleCloseDropDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          ドロップテーブル管理 - {selectedMonster?.name}
        </DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            このモンスターがドロップするアイテムを管理します。
          </Typography>
          {/* ここにドロップテーブル管理コンポーネントを追加 */}
          <Alert severity="info">
            ドロップテーブル管理機能は今後実装予定です。
          </Alert>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDropDialog}>閉じる</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default MonsterList;
