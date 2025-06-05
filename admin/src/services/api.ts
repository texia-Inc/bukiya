import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'
import type {
  BaseResponse,
  PaginatedResponse,
  WeaponMaster,
  WeaponMasterCreate,
  WeaponMasterUpdate,
  WeaponListParams,
  MaterialMaster,
  MaterialMasterCreate,
  MaterialMasterUpdate,
  MaterialListParams,
  CraftingRecipe,
  CraftingRecipeCreate,
  CraftingRecipeUpdate,
  RecipeListParams,
  Player,
  PlayerListParams,
  WeaponType,
  RarityLevel,
  DashboardStats,
  AdventurerMaster,
  AdventurerMasterCreate,
  AdventurerMasterUpdate,
  AdventurerListParams,
  MonsterMaster,
  MonsterMasterCreate,
  MonsterMasterUpdate,
  MonsterListParams,
  QuestAreaMaster,
  QuestAreaMasterCreate,
  QuestAreaMasterUpdate,
  QuestAreaListParams,
  MissionTemplate,
  MissionTemplateCreate,
  MissionTemplateUpdate,
  MissionTemplateListParams,
} from '../types'

const baseQuery = fetchBaseQuery({
  baseUrl: 'http://localhost:8000/api/v1/',
  prepareHeaders: (headers) => {
    // TODO: 認証トークンの設定
    // const token = localStorage.getItem('token')
    // if (token) {
    //   headers.set('authorization', `Bearer ${token}`)
    // }
    headers.set('Content-Type', 'application/json')
    return headers
  },
})

export const adminApi = createApi({
  reducerPath: 'adminApi',
  baseQuery,
  tagTypes: ['Weapon', 'Material', 'Recipe', 'Player', 'WeaponType', 'Rarity', 'Adventurer', 'Monster', 'QuestArea', 'MissionTemplate', 'Dashboard'],
  endpoints: (builder) => ({
    // ダッシュボード統計
    getDashboardStats: builder.query<BaseResponse<DashboardStats>, void>({
      query: () => 'dashboard/stats',
      providesTags: ['Dashboard'],
    }),

    // 武器タイプマスター
    getWeaponTypes: builder.query<BaseResponse<WeaponType[]>, void>({
      query: () => 'weapon-types',
      providesTags: ['WeaponType'],
    }),

    // レアリティレベルマスター
    getRarityLevels: builder.query<BaseResponse<RarityLevel[]>, void>({
      query: () => 'rarity-levels',
      providesTags: ['Rarity'],
    }),

    // 武器マスター（管理画面用・認証不要）
    getWeapons: builder.query<PaginatedResponse<WeaponMaster>, WeaponListParams>({
      query: (params) => ({
        url: 'weapons/admin/list',
        params: {
          page: params.page || 1,
          limit: params.limit || 20,
          weapon_type_id: params.weapon_type_id,
          rarity_id: params.rarity_id,
          min_level: params.min_level,
          max_level: params.max_level
        }
      }),
      providesTags: ['Weapon'],
    }),

    getWeapon: builder.query<BaseResponse<WeaponMaster>, number>({
      query: (id) => `weapons/${id}`,
      providesTags: (result, error, id) => [{ type: 'Weapon', id }],
    }),

    createWeapon: builder.mutation<BaseResponse<WeaponMaster>, WeaponMasterCreate>({
      query: (weapon) => ({
        url: 'weapons/admin/create',
        method: 'POST',
        body: weapon,
      }),
      invalidatesTags: ['Weapon'],
    }),

    updateWeapon: builder.mutation<BaseResponse<WeaponMaster>, { id: number; weapon: WeaponMasterUpdate }>({
      query: ({ id, weapon }) => ({
        url: `weapons/admin/${id}`,
        method: 'PUT',
        body: weapon,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Weapon', id }],
    }),

    deleteWeapon: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `weapons/admin/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Weapon'],
    }),

    // 素材マスター（管理画面用）
    getMaterials: builder.query<PaginatedResponse<MaterialMaster>, MaterialListParams>({
      query: (params) => ({
        url: 'materials',
        params: {
          page: params.page,
          limit: params.limit,
          rarity_id: params.rarity_id,
          min_price: params.min_price,
          max_price: params.max_price
        }
      }),
      providesTags: ['Material'],
    }),

    getMaterial: builder.query<BaseResponse<MaterialMaster>, number>({
      query: (id) => `materials/${id}`,
      providesTags: (result, error, id) => [{ type: 'Material', id }],
    }),

    createMaterial: builder.mutation<BaseResponse<MaterialMaster>, MaterialMasterCreate>({
      query: (material) => ({
        url: 'materials/admin/create',
        method: 'POST',
        body: material,
      }),
      invalidatesTags: ['Material'],
    }),

    updateMaterial: builder.mutation<BaseResponse<MaterialMaster>, { id: number; material: MaterialMasterUpdate }>({
      query: ({ id, material }) => ({
        url: `materials/admin/${id}`,
        method: 'PUT',
        body: material,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Material', id }],
    }),

    deleteMaterial: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `materials/admin/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Material'],
    }),

    // クラフトレシピマスター（管理画面用）
    getRecipes: builder.query<PaginatedResponse<CraftingRecipe>, RecipeListParams>({
      query: (params) => ({
        url: 'recipes',
        params: {
          page: params.page,
          limit: params.limit,
          weapon_type_id: params.weapon_type_id,
          rarity_id: params.rarity_id,
          max_level: params.max_level
        }
      }),
      providesTags: ['Recipe'],
    }),

    getRecipe: builder.query<BaseResponse<CraftingRecipe>, number>({
      query: (id) => `recipes/${id}`,
      providesTags: (result, error, id) => [{ type: 'Recipe', id }],
    }),

    createRecipe: builder.mutation<BaseResponse<CraftingRecipe>, CraftingRecipeCreate>({
      query: (recipe) => ({
        url: 'recipes/admin/create',
        method: 'POST',
        body: recipe,
      }),
      invalidatesTags: ['Recipe'],
    }),

    updateRecipe: builder.mutation<BaseResponse<CraftingRecipe>, { id: number; recipe: CraftingRecipeUpdate }>({
      query: ({ id, recipe }) => ({
        url: `recipes/admin/${id}`,
        method: 'PUT',
        body: recipe,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Recipe', id }],
    }),

    deleteRecipe: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `recipes/admin/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Recipe'],
    }),

    // プレイヤー管理（管理画面用）
    getPlayers: builder.query<BaseResponse<Player[]>, PlayerListParams>({
      query: (params) => ({
        url: 'players/admin',
        params: {
          page: params.page,
          limit: params.limit,
          min_level: params.min_level,
          max_level: params.max_level,
          is_banned: params.is_banned
        }
      }),
      providesTags: ['Player'],
    }),

    getPlayer: builder.query<BaseResponse<any>, string>({
      query: (id) => `players/admin/${id}`,
      providesTags: (result, error, id) => [{ type: 'Player', id }],
    }),

    updatePlayer: builder.mutation<BaseResponse<Player>, { id: string; player: any }>({
      query: ({ id, player }) => ({
        url: `players/admin/${id}`,
        method: 'PUT',
        body: player,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Player', id }],
    }),

    banPlayer: builder.mutation<BaseResponse<any>, { id: string; reason: string; expires_at?: string }>({
      query: ({ id, reason, expires_at }) => ({
        url: `players/admin/${id}/ban`,
        method: 'POST',
        body: { reason, expires_at },
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Player', id }],
    }),

    unbanPlayer: builder.mutation<BaseResponse<any>, string>({
      query: (id) => ({
        url: `players/admin/${id}/unban`,
        method: 'POST',
      }),
      invalidatesTags: (result, error, id) => [{ type: 'Player', id }],
    }),

    // 冒険者マスター（管理画面用）
    getAdventurers: builder.query<PaginatedResponse<AdventurerMaster>, AdventurerListParams>({
      query: (params) => ({
        url: 'admin/adventurers',
        params: {
          page: params.page,
          limit: params.limit,
          search: params.search,
          profession: params.profession,
          is_active: params.is_active
        }
      }),
      providesTags: ['Adventurer'],
    }),

    getAdventurer: builder.query<BaseResponse<AdventurerMaster>, number>({
      query: (id) => `admin/adventurers/${id}`,
      providesTags: (result, error, id) => [{ type: 'Adventurer', id }],
    }),

    createAdventurer: builder.mutation<BaseResponse<AdventurerMaster>, AdventurerMasterCreate>({
      query: (adventurer) => ({
        url: 'admin/adventurers',
        method: 'POST',
        body: adventurer,
      }),
      invalidatesTags: ['Adventurer'],
    }),

    updateAdventurer: builder.mutation<BaseResponse<AdventurerMaster>, { id: number; adventurer: AdventurerMasterUpdate }>({
      query: ({ id, adventurer }) => ({
        url: `admin/adventurers/${id}`,
        method: 'PUT',
        body: adventurer,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Adventurer', id }],
    }),

    deleteAdventurer: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `admin/adventurers/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Adventurer'],
    }),

    // モンスターマスター（管理画面用）
    getMonsters: builder.query<PaginatedResponse<MonsterMaster>, MonsterListParams>({
      query: (params) => ({
        url: 'monsters',
        params: {
          page: params.page,
          limit: params.limit,
          search: params.search,
          monster_type: params.monster_type,
          is_active: params.is_active
        }
      }),
      providesTags: ['Monster'],
    }),

    getMonster: builder.query<BaseResponse<MonsterMaster>, number>({
      query: (id) => `monsters/${id}`,
      providesTags: (result, error, id) => [{ type: 'Monster', id }],
    }),

    createMonster: builder.mutation<BaseResponse<MonsterMaster>, MonsterMasterCreate>({
      query: (monster) => ({
        url: 'admin/monsters',
        method: 'POST',
        body: monster,
      }),
      invalidatesTags: ['Monster'],
    }),

    updateMonster: builder.mutation<BaseResponse<MonsterMaster>, { id: number; monster: MonsterMasterUpdate }>({
      query: ({ id, monster }) => ({
        url: `admin/monsters/${id}`,
        method: 'PUT',
        body: monster,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Monster', id }],
    }),

    deleteMonster: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `admin/monsters/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Monster'],
    }),

    // クエストエリアマスター（管理画面用）
    getQuestAreas: builder.query<PaginatedResponse<QuestAreaMaster>, QuestAreaListParams>({
      query: (params) => ({
        url: 'admin/quest-areas',
        params: {
          page: params.page,
          limit: params.limit,
          search: params.search,
          is_active: params.is_active
        }
      }),
      providesTags: ['QuestArea'],
    }),

    getQuestArea: builder.query<BaseResponse<QuestAreaMaster>, number>({
      query: (id) => `admin/quest-areas/${id}`,
      providesTags: (result, error, id) => [{ type: 'QuestArea', id }],
    }),

    createQuestArea: builder.mutation<BaseResponse<QuestAreaMaster>, QuestAreaMasterCreate>({
      query: (area) => ({
        url: 'admin/quest-areas',
        method: 'POST',
        body: area,
      }),
      invalidatesTags: ['QuestArea'],
    }),

    updateQuestArea: builder.mutation<BaseResponse<QuestAreaMaster>, { id: number; area: QuestAreaMasterUpdate }>({
      query: ({ id, area }) => ({
        url: `admin/quest-areas/${id}`,
        method: 'PUT',
        body: area,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'QuestArea', id }],
    }),

    deleteQuestArea: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `admin/quest-areas/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['QuestArea'],
    }),

    // ミッションテンプレート（管理画面用）
    getMissionTemplates: builder.query<BaseResponse<MissionTemplate[]>, MissionTemplateListParams>({
      query: (params) => ({
        url: 'missions/admin/templates',
        params: {
          page: params.page,
          limit: params.limit,
          search: params.search,
          mission_type: params.mission_type,
          is_active: params.is_active
        }
      }),
      providesTags: ['MissionTemplate'],
    }),

    createMissionTemplate: builder.mutation<BaseResponse<MissionTemplate>, MissionTemplateCreate>({
      query: (template) => ({
        url: 'missions/admin/templates',
        method: 'POST',
        body: template,
      }),
      invalidatesTags: ['MissionTemplate'],
    }),

    updateMissionTemplate: builder.mutation<BaseResponse<MissionTemplate>, { id: number; template: MissionTemplateUpdate }>({
      query: ({ id, template }) => ({
        url: `missions/admin/templates/${id}`,
        method: 'PUT',
        body: template,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'MissionTemplate', id }],
    }),

    deleteMissionTemplate: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `missions/admin/templates/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['MissionTemplate'],
    }),
  }),
})

export const {
  useGetDashboardStatsQuery,
  useGetWeaponTypesQuery,
  useGetRarityLevelsQuery,
  useGetWeaponsQuery,
  useGetWeaponQuery,
  useCreateWeaponMutation,
  useUpdateWeaponMutation,
  useDeleteWeaponMutation,
  useGetMaterialsQuery,
  useGetMaterialQuery,
  useCreateMaterialMutation,
  useUpdateMaterialMutation,
  useDeleteMaterialMutation,
  useGetRecipesQuery,
  useGetRecipeQuery,
  useCreateRecipeMutation,
  useUpdateRecipeMutation,
  useDeleteRecipeMutation,
  useGetPlayersQuery,
  useGetPlayerQuery,
  useUpdatePlayerMutation,
  useBanPlayerMutation,
  useUnbanPlayerMutation,
  useGetAdventurersQuery,
  useGetAdventurerQuery,
  useCreateAdventurerMutation,
  useUpdateAdventurerMutation,
  useDeleteAdventurerMutation,
  useGetMonstersQuery,
  useGetMonsterQuery,
  useCreateMonsterMutation,
  useUpdateMonsterMutation,
  useDeleteMonsterMutation,
  useGetQuestAreasQuery,
  useGetQuestAreaQuery,
  useCreateQuestAreaMutation,
  useUpdateQuestAreaMutation,
  useDeleteQuestAreaMutation,
  useGetMissionTemplatesQuery,
  useCreateMissionTemplateMutation,
  useUpdateMissionTemplateMutation,
  useDeleteMissionTemplateMutation,
} = adminApi