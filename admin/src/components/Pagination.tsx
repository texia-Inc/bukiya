import React from 'react'
import {
  Box,
  Pagination as MuiPagination,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Typography,
} from '@mui/material'
import type { SelectChangeEvent } from '@mui/material/Select'

interface PaginationProps {
  page: number
  totalPages: number
  totalItems: number
  itemsPerPage: number
  onPageChange: (page: number) => void
  onItemsPerPageChange: (itemsPerPage: number) => void
  itemsPerPageOptions?: number[]
}

const Pagination: React.FC<PaginationProps> = ({
  page,
  totalPages,
  totalItems,
  itemsPerPage,
  onPageChange,
  onItemsPerPageChange,
  itemsPerPageOptions = [10, 20, 50, 100],
}) => {
  const handlePageChange = (_: React.ChangeEvent<unknown>, value: number) => {
    onPageChange(value)
  }

  const handleItemsPerPageChange = (event: SelectChangeEvent<number>) => {
    onItemsPerPageChange(event.target.value as number)
  }

  // 現在表示されているアイテムの範囲を計算
  const startItem = (page - 1) * itemsPerPage + 1
  const endItem = Math.min(page * itemsPerPage, totalItems)

  return (
    <Box
      display="flex"
      justifyContent="space-between"
      alignItems="center"
      sx={{ mt: 2, flexWrap: 'wrap', gap: 2 }}
    >
      {/* アイテム数表示 */}
      <Typography variant="body2" color="textSecondary">
        {totalItems > 0 
          ? `${startItem}-${endItem} / ${totalItems}件を表示`
          : '0件'
        }
      </Typography>

      {/* ページネーションとページサイズ選択 */}
      <Box display="flex" alignItems="center" gap={2}>
        {/* ページサイズ選択 */}
        <FormControl size="small" sx={{ minWidth: 120 }}>
          <InputLabel>表示件数</InputLabel>
          <Select
            value={itemsPerPage}
            label="表示件数"
            onChange={handleItemsPerPageChange}
          >
            {itemsPerPageOptions.map((option) => (
              <MenuItem key={option} value={option}>
                {option}件
              </MenuItem>
            ))}
          </Select>
        </FormControl>

        {/* ページネーション */}
        {totalPages > 1 && (
          <MuiPagination
            count={totalPages}
            page={page}
            onChange={handlePageChange}
            color="primary"
            showFirstButton
            showLastButton
          />
        )}
      </Box>
    </Box>
  )
}

export default Pagination