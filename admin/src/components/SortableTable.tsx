import React, { useState, useMemo } from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  TableSortLabel,
  Box,
} from '@mui/material';
import { visuallyHidden } from '@mui/utils';

export type SortOrder = 'asc' | 'desc';

export interface SortableColumn {
  id: string;
  label: string;
  numeric?: boolean;
  align?: 'left' | 'center' | 'right';
  sortable?: boolean;
  renderCell?: (row: any) => React.ReactNode;
}

interface SortableTableProps {
  columns: SortableColumn[];
  data: any[];
  defaultSortBy?: string;
  defaultSortOrder?: SortOrder;
  onRowClick?: (row: any) => void;
}

function descendingComparator<T>(a: T, b: T, orderBy: keyof T) {
  // ネストされたオブジェクトのプロパティにアクセス
  const getNestedValue = (obj: any, path: string) => {
    return path.split('.').reduce((current, key) => current?.[key], obj);
  };

  const aValue = getNestedValue(a, orderBy as string);
  const bValue = getNestedValue(b, orderBy as string);

  if (bValue < aValue) {
    return -1;
  }
  if (bValue > aValue) {
    return 1;
  }
  return 0;
}

function getComparator<Key extends keyof any>(
  order: SortOrder,
  orderBy: Key,
): (a: { [key in Key]: number | string }, b: { [key in Key]: number | string }) => number {
  return order === 'desc'
    ? (a, b) => descendingComparator(a, b, orderBy)
    : (a, b) => -descendingComparator(a, b, orderBy);
}

function stableSort<T>(array: readonly T[], comparator: (a: T, b: T) => number) {
  const stabilizedThis = array.map((el, index) => [el, index] as [T, number]);
  stabilizedThis.sort((a, b) => {
    const order = comparator(a[0], b[0]);
    if (order !== 0) {
      return order;
    }
    return a[1] - b[1];
  });
  return stabilizedThis.map((el) => el[0]);
}

const SortableTable: React.FC<SortableTableProps> = ({
  columns,
  data,
  defaultSortBy,
  defaultSortOrder = 'asc',
  onRowClick,
}) => {
  const [order, setOrder] = useState<SortOrder>(defaultSortOrder);
  const [orderBy, setOrderBy] = useState<string>(defaultSortBy || columns[0]?.id || '');

  const handleRequestSort = (property: string) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const createSortHandler = (property: string) => () => {
    handleRequestSort(property);
  };

  const sortedData = useMemo(() => {
    if (!orderBy) return data;
    return stableSort(data, getComparator(order, orderBy));
  }, [data, order, orderBy]);

  const renderCellContent = (column: SortableColumn, row: any) => {
    if (column.renderCell) {
      return column.renderCell(row);
    }

    // ネストされたオブジェクトのプロパティにアクセス
    const getNestedValue = (obj: any, path: string) => {
      return path.split('.').reduce((current, key) => current?.[key], obj);
    };

    const value = getNestedValue(row, column.id);
    return value;
  };

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            {columns.map((column) => (
              <TableCell
                key={column.id}
                align={column.align || 'left'}
                sortDirection={orderBy === column.id ? order : false}
              >
                {column.sortable !== false ? (
                  <TableSortLabel
                    active={orderBy === column.id}
                    direction={orderBy === column.id ? order : 'asc'}
                    onClick={createSortHandler(column.id)}
                  >
                    {column.label}
                    {orderBy === column.id ? (
                      <Box component="span" sx={visuallyHidden}>
                        {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                      </Box>
                    ) : null}
                  </TableSortLabel>
                ) : (
                  column.label
                )}
              </TableCell>
            ))}
          </TableRow>
        </TableHead>
        <TableBody>
          {sortedData.map((row, index) => (
            <TableRow
              key={row.id || index}
              hover
              onClick={onRowClick ? () => onRowClick(row) : undefined}
              sx={{ cursor: onRowClick ? 'pointer' : 'default' }}
            >
              {columns.map((column) => (
                <TableCell
                  key={column.id}
                  align={column.align || 'left'}
                >
                  {renderCellContent(column, row)}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
};

export default SortableTable;
export type { SortableColumn, SortOrder };