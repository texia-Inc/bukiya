import React from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Box,
  Chip,
  Card,
  CardContent,
  Stack,
  Divider,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Person as PersonIcon,
  AccountBalance as GoldIcon,
  Diamond as GemsIcon,
  Store as ShopIcon,
  Star as ReputationIcon,
  Schedule as TimeIcon,
  TrendingUp as StatsIcon,
} from '@mui/icons-material';
import { useGetPlayerQuery } from '../services/api';

interface PlayerDetailDialogProps {
  open: boolean;
  playerId: string | null;
  onClose: () => void;
  onEdit: (player: any) => void;
  onBan: (player: any) => void;
}

export const PlayerDetailDialog: React.FC<PlayerDetailDialogProps> = ({
  open,
  playerId,
  onClose,
  onEdit,
  onBan,
}) => {
  const { data: playerData, isLoading, error } = useGetPlayerQuery(playerId!, {
    skip: !playerId,
  });

  if (!playerId) return null;

  const player = playerData?.data?.player;
  const statistics = playerData?.data?.statistics;
  const weapons = playerData?.data?.weapons || [];
  const materials = playerData?.data?.materials || [];

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('ja-JP');
  };

  const formatDuration = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}時間${minutes}分`;
  };

  return (
    <Dialog 
      open={open} 
      onClose={onClose}
      maxWidth="lg"
      fullWidth
    >
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <PersonIcon />
        プレイヤー詳細
      </DialogTitle>
      <DialogContent>
        {isLoading && (
          <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
            <CircularProgress />
          </Box>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            プレイヤー情報の取得に失敗しました
          </Alert>
        )}

        {player && (
          <Stack spacing={3}>
            {/* 基本情報 */}
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <PersonIcon />
                  基本情報
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
                  <Box sx={{ flex: '1 1 300px' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                      <Typography variant="body2" color="textSecondary" sx={{ minWidth: 100 }}>
                        ユーザー名:
                      </Typography>
                      <Typography variant="body1" fontWeight="medium">
                        {player.username}
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                      <Typography variant="body2" color="textSecondary" sx={{ minWidth: 100 }}>
                        メール:
                      </Typography>
                      <Typography variant="body1">
                        {player.email}
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                      <Typography variant="body2" color="textSecondary" sx={{ minWidth: 100 }}>
                        状態:
                      </Typography>
                      <Chip
                        label={player.is_active ? 'アクティブ' : 'BAN済み'}
                        color={player.is_active ? 'success' : 'error'}
                        size="small"
                      />
                    </Box>
                  </Box>
                  <Box sx={{ flex: '1 1 300px' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                      <Typography variant="body2" color="textSecondary" sx={{ minWidth: 100 }}>
                        登録日:
                      </Typography>
                      <Typography variant="body1">
                        {formatDate(player.created_at)}
                      </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                      <Typography variant="body2" color="textSecondary" sx={{ minWidth: 100 }}>
                        最終ログイン:
                      </Typography>
                      <Typography variant="body1">
                        {formatDate(player.last_login)}
                      </Typography>
                    </Box>
                  </Box>
                </Box>
              </CardContent>
            </Card>

            {/* ゲーム進捗 */}
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <StatsIcon />
                  ゲーム進捗
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
                  <Box sx={{ flex: '1 1 150px' }}>
                    <Box sx={{ textAlign: 'center', p: 2, bgcolor: 'gold.light', borderRadius: 1 }}>
                      <GoldIcon sx={{ fontSize: 32, color: 'gold.main', mb: 1 }} />
                      <Typography variant="h6">{player.gold.toLocaleString()}G</Typography>
                      <Typography variant="caption" color="textSecondary">ゴールド</Typography>
                    </Box>
                  </Box>
                  <Box sx={{ flex: '1 1 150px' }}>
                    <Box sx={{ textAlign: 'center', p: 2, bgcolor: 'primary.light', borderRadius: 1 }}>
                      <GemsIcon sx={{ fontSize: 32, color: 'primary.main', mb: 1 }} />
                      <Typography variant="h6">{player.gems.toLocaleString()}</Typography>
                      <Typography variant="caption" color="textSecondary">ジェム</Typography>
                    </Box>
                  </Box>
                  <Box sx={{ flex: '1 1 150px' }}>
                    <Box sx={{ textAlign: 'center', p: 2, bgcolor: 'secondary.light', borderRadius: 1 }}>
                      <ShopIcon sx={{ fontSize: 32, color: 'secondary.main', mb: 1 }} />
                      <Typography variant="h6">Lv.{player.shop_level}</Typography>
                      <Typography variant="caption" color="textSecondary">ショップレベル</Typography>
                    </Box>
                  </Box>
                  <Box sx={{ flex: '1 1 150px' }}>
                    <Box sx={{ textAlign: 'center', p: 2, bgcolor: 'warning.light', borderRadius: 1 }}>
                      <ReputationIcon sx={{ fontSize: 32, color: 'warning.main', mb: 1 }} />
                      <Typography variant="h6">{player.reputation}</Typography>
                      <Typography variant="caption" color="textSecondary">評判</Typography>
                    </Box>
                  </Box>
                </Box>
              </CardContent>
            </Card>

            {/* 統計情報 */}
            {statistics && (
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <TimeIcon />
                    プレイ統計
                  </Typography>
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
                    <Box sx={{ flex: '1 1 300px' }}>
                      <Stack spacing={1}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">総プレイ時間:</Typography>
                          <Typography variant="body2">{formatDuration(statistics.total_play_time_seconds)}</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">セッション数:</Typography>
                          <Typography variant="body2">{statistics.session_count}回</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">平均セッション時間:</Typography>
                          <Typography variant="body2">{formatDuration(statistics.average_session_duration)}</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">総獲得ゴールド:</Typography>
                          <Typography variant="body2">{statistics.total_gold_earned.toLocaleString()}G</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">総消費ゴールド:</Typography>
                          <Typography variant="body2">{statistics.total_gold_spent.toLocaleString()}G</Typography>
                        </Box>
                      </Stack>
                    </Box>
                    <Box sx={{ flex: '1 1 300px' }}>
                      <Stack spacing={1}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">作成武器数:</Typography>
                          <Typography variant="body2">{statistics.weapons_crafted}個</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">エンチャント試行:</Typography>
                          <Typography variant="body2">{statistics.enchants_attempted}回</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">エンチャント成功:</Typography>
                          <Typography variant="body2">{statistics.enchants_succeeded}回</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">最高武器攻撃力:</Typography>
                          <Typography variant="body2">{statistics.highest_weapon_attack}</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                          <Typography variant="body2" color="textSecondary">エンチャント成功率:</Typography>
                          <Typography variant="body2">{Math.round(statistics.enchant_success_rate * 100)}%</Typography>
                        </Box>
                      </Stack>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            )}

            {/* 所持武器 */}
            {weapons.length > 0 && (
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    所持武器 (最新10件)
                  </Typography>
                  <TableContainer component={Paper} variant="outlined">
                    <Table size="small">
                      <TableHead>
                        <TableRow>
                          <TableCell>武器名</TableCell>
                          <TableCell align="right">攻撃力</TableCell>
                          <TableCell align="right">エンチャントLv</TableCell>
                          <TableCell>取得日時</TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        {weapons.map((weapon: any, index: number) => (
                          <TableRow key={index}>
                            <TableCell>{weapon.weapon_name}</TableCell>
                            <TableCell align="right">{weapon.attack}</TableCell>
                            <TableCell align="right">+{weapon.enchant_level}</TableCell>
                            <TableCell>{formatDate(weapon.created_at)}</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </TableContainer>
                </CardContent>
              </Card>
            )}

            {/* 所持素材 */}
            {materials.length > 0 && (
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    所持素材 (最新10件)
                  </Typography>
                  <TableContainer component={Paper} variant="outlined">
                    <Table size="small">
                      <TableHead>
                        <TableRow>
                          <TableCell>素材名</TableCell>
                          <TableCell align="right">数量</TableCell>
                          <TableCell>更新日時</TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        {materials.map((material: any, index: number) => (
                          <TableRow key={index}>
                            <TableCell>{material.material_name}</TableCell>
                            <TableCell align="right">{material.quantity}</TableCell>
                            <TableCell>{formatDate(material.updated_at)}</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </TableContainer>
                </CardContent>
              </Card>
            )}
          </Stack>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>
          閉じる
        </Button>
        {player && (
          <>
            <Button 
              onClick={() => onEdit(player)} 
              variant="outlined"
            >
              編集
            </Button>
            <Button 
              onClick={() => onBan(player)} 
              color={player.is_active ? 'error' : 'success'}
              variant="contained"
            >
              {player.is_active ? 'BAN' : 'BAN解除'}
            </Button>
          </>
        )}
      </DialogActions>
    </Dialog>
  );
};
