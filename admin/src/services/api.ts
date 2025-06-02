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
  tagTypes: ['Weapon', 'Material', 'Recipe', 'Player', 'WeaponType', 'Rarity', 'Adventurer', 'Monster', 'QuestArea', 'MissionTemplate'],
  endpoints: (builder) => ({
    // 注意: 以下のエンドポイントは実装されていないため、モックデータを使用
    // getDashboardStats: 実装されていない
    // getWeaponTypes: 実装されていない  
    // getRarityLevels: 実装されていない

    // 武器マスター（管理画面用・認証不要）
    getWeapons: builder.query<PaginatedResponse<WeaponMaster>, WeaponListParams>({
      query: (params) => ({
        url: 'weapons/admin/list',
        params,
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

    // 素材マスター（管理画面用・認証不要）
    getMaterials: builder.query<PaginatedResponse<MaterialMaster>, MaterialListParams>({
      query: (params) => ({
        url: 'materials/admin/list',
        params,
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

    // 合成レシピ（管理画面用・認証不要）
    getRecipes: builder.query<PaginatedResponse<CraftingRecipe>, RecipeListParams>({
      query: (params) => ({
        url: 'crafting/recipes/admin/list',
        params,
      }),
      providesTags: ['Recipe'],
    }),

    getRecipe: builder.query<BaseResponse<CraftingRecipe>, number>({
      query: (id) => `crafting/recipes/${id}`,
      providesTags: (result, error, id) => [{ type: 'Recipe', id }],
    }),

    createRecipe: builder.mutation<BaseResponse<CraftingRecipe>, CraftingRecipeCreate>({
      query: (recipe) => ({
        url: 'crafting/recipes/admin/create',
        method: 'POST',
        body: recipe,
      }),
      invalidatesTags: ['Recipe'],
    }),

    updateRecipe: builder.mutation<BaseResponse<CraftingRecipe>, { id: number; recipe: CraftingRecipeUpdate }>({
      query: ({ id, recipe }) => ({
        url: `crafting/recipes/admin/${id}`,
        method: 'PUT',
        body: recipe,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: 'Recipe', id }],
    }),

    deleteRecipe: builder.mutation<BaseResponse<void>, number>({
      query: (id) => ({
        url: `crafting/recipes/admin/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['Recipe'],
    }),

    // プレイヤー（管理画面用・認証不要）
    getPlayers: builder.query<BaseResponse<Player[]>, PlayerListParams>({
      query: (params) => ({
        url: 'players/admin/list',
        params,
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
    getAdventurers: builder.query<BaseResponse<AdventurerMaster[]>, AdventurerListParams>({
      query: (params) => ({
        url: 'admin/adventurers',
        params,
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
    getMonsters: builder.query<BaseResponse<MonsterMaster[]>, MonsterListParams>({
      query: (params) => ({
        url: 'admin/monsters',
        params,
      }),
      providesTags: ['Monster'],
    }),

    getMonster: builder.query<BaseResponse<MonsterMaster>, number>({
      query: (id) => `admin/monsters/${id}`,
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
    getQuestAreas: builder.query<BaseResponse<QuestAreaMaster[]>, QuestAreaListParams>({
      query: (params) => ({
        url: 'admin/quest-areas',
        params,
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
        params,
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
