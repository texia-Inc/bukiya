--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dragoneventstatus; Type: TYPE; Schema: public; Owner: bukiya_user
--

CREATE TYPE public.dragoneventstatus AS ENUM (
    'SCHEDULED',
    'ACTIVE',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public.dragoneventstatus OWNER TO bukiya_user;

--
-- Name: update_player_statistics(); Type: FUNCTION; Schema: public; Owner: bukiya_user
--

CREATE FUNCTION public.update_player_statistics() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- ゴールド変動時の統計更新
    IF TG_TABLE_NAME = 'players' AND OLD.gold != NEW.gold THEN
        UPDATE player_statistics 
        SET 
            total_gold_earned = total_gold_earned + GREATEST(NEW.gold - OLD.gold, 0),
            updated_at = CURRENT_TIMESTAMP
        WHERE player_id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_player_statistics() OWNER TO bukiya_user;

--
-- Name: update_season_masters_updated_at(); Type: FUNCTION; Schema: public; Owner: bukiya_user
--

CREATE FUNCTION public.update_season_masters_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    NEW.updated_at = NOW();
                    RETURN NEW;
                END;
                $$;


ALTER FUNCTION public.update_season_masters_updated_at() OWNER TO bukiya_user;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: bukiya_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO bukiya_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abilities; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.abilities (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text NOT NULL,
    effect_type character varying(50) NOT NULL,
    effect_value integer NOT NULL,
    effect_percentage boolean DEFAULT false,
    required_weapon_types text[],
    required_rarity_level integer DEFAULT 1,
    is_active boolean DEFAULT true,
    rarity character varying(20) DEFAULT 'common'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.abilities OWNER TO bukiya_user;

--
-- Name: active_processes; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.active_processes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    process_type character varying(50) NOT NULL,
    status character varying(20) DEFAULT 'in_progress'::character varying,
    started_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    duration_minutes integer NOT NULL,
    completed_at timestamp with time zone,
    process_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    result_data jsonb,
    rewards_claimed boolean DEFAULT false,
    CONSTRAINT active_processes_duration_check CHECK ((duration_minutes > 0))
);


ALTER TABLE public.active_processes OWNER TO bukiya_user;

--
-- Name: admin_logs; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.admin_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_user character varying(100) NOT NULL,
    action_type character varying(50) NOT NULL,
    target_type character varying(50) NOT NULL,
    target_id character varying(100),
    old_values jsonb,
    new_values jsonb,
    reason text,
    ip_address inet,
    session_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admin_logs OWNER TO bukiya_user;

--
-- Name: adventurer_characters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_characters (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    title character varying(100),
    profession character varying(20) NOT NULL,
    rarity character varying(20) DEFAULT 'common'::character varying NOT NULL,
    base_level integer DEFAULT 1 NOT NULL,
    max_level integer DEFAULT 50 NOT NULL,
    max_trust_level integer DEFAULT 100 NOT NULL,
    unlock_player_level integer DEFAULT 1 NOT NULL,
    unlock_condition text,
    base_stats jsonb DEFAULT '{"magic": 3, "speed": 8, "attack": 10, "defense": 5}'::jsonb,
    growth_rates jsonb DEFAULT '{"magic": 1.0, "speed": 1.0, "attack": 1.2, "defense": 1.1}'::jsonb,
    preferred_weapon_types text[] DEFAULT ARRAY[]::text[],
    elemental_affinity character varying(20),
    personality character varying(50) DEFAULT 'normal'::character varying NOT NULL,
    backstory text,
    quote text,
    avatar_url character varying(255),
    color_theme character varying(7) DEFAULT '#4CAF50'::character varying,
    voice_type character varying(20),
    special_abilities jsonb DEFAULT '[]'::jsonb,
    passive_skills jsonb DEFAULT '[]'::jsonb,
    dragon_battle_eligible boolean DEFAULT false,
    leadership_bonus integer DEFAULT 0,
    team_synergy jsonb DEFAULT '{}'::jsonb,
    is_story_character boolean DEFAULT false,
    unlock_order integer DEFAULT 0,
    is_limited_time boolean DEFAULT false,
    availability_start timestamp with time zone,
    availability_end timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.adventurer_characters OWNER TO bukiya_user;

--
-- Name: adventurer_characters_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.adventurer_characters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adventurer_characters_id_seq OWNER TO bukiya_user;

--
-- Name: adventurer_characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.adventurer_characters_id_seq OWNED BY public.adventurer_characters.id;


--
-- Name: adventurer_instances; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    adventurer_master_id character varying,
    player_id uuid,
    name character varying(100) NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    trust_level integer DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'visiting'::character varying NOT NULL,
    current_quest_id uuid,
    visit_start_time timestamp with time zone,
    visit_end_time timestamp with time zone,
    is_named_character boolean DEFAULT false,
    character_id integer,
    generic_name character varying(100),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.adventurer_instances OWNER TO bukiya_user;

--
-- Name: adventurer_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_masters (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    class character varying(50),
    level_min integer DEFAULT 1,
    level_max integer DEFAULT 100,
    preferred_weapon_types text[],
    budget_min integer DEFAULT 100,
    budget_max integer DEFAULT 10000,
    personality character varying(50),
    haggle_skill integer DEFAULT 50,
    trust_base integer DEFAULT 50,
    avatar_image character varying(255),
    description text,
    spawn_rate numeric(5,4) DEFAULT 0.1000,
    visit_frequency_hours integer DEFAULT 4,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    profession character varying(50),
    level integer DEFAULT 1,
    trust_level integer DEFAULT 50,
    preferred_weapon_type character varying(50),
    avatar_url character varying(255),
    min_attack_requirement integer DEFAULT 100,
    max_budget_multiplier numeric DEFAULT 1.0,
    urgency_tendency integer DEFAULT 3,
    spawn_weight integer DEFAULT 100,
    min_player_level integer DEFAULT 1,
    max_player_level integer,
    tier character varying(20) DEFAULT 'normal'::character varying,
    progression_multiplier numeric DEFAULT 1.0,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.adventurer_masters OWNER TO bukiya_user;

--
-- Name: adventurer_purchases; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_purchases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    adventurer_instance_id uuid NOT NULL,
    weapon_id uuid NOT NULL,
    purchase_price integer NOT NULL,
    negotiated_price integer,
    satisfaction_score double precision DEFAULT 0.5,
    purchased_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.adventurer_purchases OWNER TO bukiya_user;

--
-- Name: adventurer_quests; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_quests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    adventurer_instance_id uuid NOT NULL,
    quest_area_id integer,
    player_weapon_id uuid,
    monster_id character varying(50),
    target_material_id character varying(50),
    target_material_boost double precision DEFAULT 1.0,
    target_cost integer DEFAULT 0,
    status character varying(20) DEFAULT 'in_progress'::character varying NOT NULL,
    start_time timestamp with time zone DEFAULT now() NOT NULL,
    end_time timestamp with time zone,
    success boolean,
    gold_earned integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.adventurer_quests OWNER TO bukiya_user;

--
-- Name: adventurer_requests; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    adventurer_instance_id uuid NOT NULL,
    weapon_type_id character varying,
    rarity_level_id character varying,
    budget_min integer DEFAULT 0,
    budget_max integer DEFAULT 0,
    priority_score double precision DEFAULT 1.0,
    urgency_level character varying(20) DEFAULT 'normal'::character varying,
    special_requirements json,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    fulfilled_at timestamp with time zone,
    weapon_id uuid,
    weapon_type character varying(50),
    min_attack integer,
    max_budget integer,
    preferred_rarity character varying(20),
    urgency integer DEFAULT 3,
    description text,
    deadline timestamp with time zone,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.adventurer_requests OWNER TO bukiya_user;

--
-- Name: adventurer_visits; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.adventurer_visits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    adventurer_master_id character varying(50) NOT NULL,
    visit_purpose character varying(50) NOT NULL,
    current_level integer NOT NULL,
    available_gold integer NOT NULL,
    weapon_requirements jsonb,
    material_offers jsonb,
    arrived_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    departure_time timestamp with time zone NOT NULL,
    status character varying(20) DEFAULT 'waiting'::character varying,
    interaction_data jsonb DEFAULT '{}'::jsonb,
    CONSTRAINT visits_departure_check CHECK ((departure_time > arrived_at))
);


ALTER TABLE public.adventurer_visits OWNER TO bukiya_user;

--
-- Name: area_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.area_masters (
    id character varying(30) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    required_shop_level integer DEFAULT 1,
    required_adventurer_level integer DEFAULT 1,
    base_expedition_time_minutes integer DEFAULT 60,
    danger_level integer DEFAULT 1,
    background_image character varying(255),
    theme_color character varying(7),
    is_active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT area_masters_danger_level_check CHECK (((danger_level >= 1) AND (danger_level <= 10)))
);


ALTER TABLE public.area_masters OWNER TO bukiya_user;

--
-- Name: attributes; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.attributes (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL,
    emoji character varying(10),
    color_code character varying(7) NOT NULL,
    description text,
    damage_bonus integer DEFAULT 0,
    effect_description text,
    effective_against text[],
    weak_against text[],
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attributes OWNER TO bukiya_user;

--
-- Name: character_conversations; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.character_conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    character_id integer NOT NULL,
    conversation_type character varying(50) NOT NULL,
    conversation_text text,
    trust_gained integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.character_conversations OWNER TO bukiya_user;

--
-- Name: character_unlock_logs; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.character_unlock_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    character_id integer NOT NULL,
    unlock_method character varying(50) NOT NULL,
    unlock_condition_met text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.character_unlock_logs OWNER TO bukiya_user;

--
-- Name: crafting_recipes; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.crafting_recipes (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    gold_cost integer DEFAULT 0 NOT NULL,
    success_rate real DEFAULT 1.0 NOT NULL,
    required_level integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    weapon_id integer,
    CONSTRAINT crafting_recipes_gold_cost_check CHECK ((gold_cost >= 0)),
    CONSTRAINT crafting_recipes_required_level_check CHECK ((required_level >= 1)),
    CONSTRAINT crafting_recipes_success_rate_check CHECK (((success_rate >= (0)::double precision) AND (success_rate <= (1)::double precision)))
);


ALTER TABLE public.crafting_recipes OWNER TO bukiya_user;

--
-- Name: crafting_recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.crafting_recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crafting_recipes_id_seq OWNER TO bukiya_user;

--
-- Name: crafting_recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.crafting_recipes_id_seq OWNED BY public.crafting_recipes.id;


--
-- Name: device_sessions; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.device_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_id character varying(255) NOT NULL,
    player_id uuid,
    device_name character varying(255),
    device_model character varying(255),
    platform character varying(50),
    platform_version character varying(50),
    app_version character varying(50),
    is_active boolean DEFAULT true,
    is_trusted boolean DEFAULT false,
    last_used_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone,
    ip_address character varying(45),
    user_agent text,
    refresh_token_hash character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.device_sessions OWNER TO bukiya_user;

--
-- Name: enchantment_logs; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.enchantment_logs (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    weapon_id uuid NOT NULL,
    enchantment_type_id integer NOT NULL,
    before_level integer NOT NULL,
    after_level integer NOT NULL,
    result character varying(20) NOT NULL,
    cost integer NOT NULL,
    materials_used json,
    success_rate double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.enchantment_logs OWNER TO bukiya_user;

--
-- Name: COLUMN enchantment_logs.before_level; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.before_level IS '強化前レベル';


--
-- Name: COLUMN enchantment_logs.after_level; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.after_level IS '強化後レベル';


--
-- Name: COLUMN enchantment_logs.result; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.result IS '結果 (success, failure, destroy)';


--
-- Name: COLUMN enchantment_logs.cost; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.cost IS 'コスト';


--
-- Name: COLUMN enchantment_logs.materials_used; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.materials_used IS '使用素材';


--
-- Name: COLUMN enchantment_logs.success_rate; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_logs.success_rate IS '成功率';


--
-- Name: enchantment_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.enchantment_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.enchantment_logs_id_seq OWNER TO bukiya_user;

--
-- Name: enchantment_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.enchantment_logs_id_seq OWNED BY public.enchantment_logs.id;


--
-- Name: enchantment_materials; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.enchantment_materials (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    rarity character varying(20),
    effect_type character varying(50),
    success_rate_bonus double precision,
    cost_multiplier double precision,
    max_stack integer,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.enchantment_materials OWNER TO bukiya_user;

--
-- Name: COLUMN enchantment_materials.name; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.name IS '素材名';


--
-- Name: COLUMN enchantment_materials.description; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.description IS '説明';


--
-- Name: COLUMN enchantment_materials.rarity; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.rarity IS 'レアリティ';


--
-- Name: COLUMN enchantment_materials.effect_type; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.effect_type IS '効果タイプ';


--
-- Name: COLUMN enchantment_materials.success_rate_bonus; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.success_rate_bonus IS '成功率ボーナス';


--
-- Name: COLUMN enchantment_materials.cost_multiplier; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.cost_multiplier IS 'コスト倍率';


--
-- Name: COLUMN enchantment_materials.max_stack; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.max_stack IS '最大所持数';


--
-- Name: COLUMN enchantment_materials.is_active; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_materials.is_active IS '有効フラグ';


--
-- Name: enchantment_materials_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.enchantment_materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.enchantment_materials_id_seq OWNER TO bukiya_user;

--
-- Name: enchantment_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.enchantment_materials_id_seq OWNED BY public.enchantment_materials.id;


--
-- Name: enchantment_types; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.enchantment_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    effect_type character varying(50) NOT NULL,
    effect_value double precision NOT NULL,
    max_level integer,
    base_success_rate double precision,
    base_cost integer,
    required_materials json,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.enchantment_types OWNER TO bukiya_user;

--
-- Name: COLUMN enchantment_types.name; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.name IS 'エンチャント名';


--
-- Name: COLUMN enchantment_types.description; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.description IS '説明';


--
-- Name: COLUMN enchantment_types.effect_type; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.effect_type IS '効果タイプ (attack, defense, speed, etc.)';


--
-- Name: COLUMN enchantment_types.effect_value; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.effect_value IS '効果値';


--
-- Name: COLUMN enchantment_types.max_level; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.max_level IS '最大レベル';


--
-- Name: COLUMN enchantment_types.base_success_rate; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.base_success_rate IS '基本成功率';


--
-- Name: COLUMN enchantment_types.base_cost; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.base_cost IS '基本コスト';


--
-- Name: COLUMN enchantment_types.required_materials; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.required_materials IS '必要素材';


--
-- Name: COLUMN enchantment_types.is_active; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.enchantment_types.is_active IS '有効フラグ';


--
-- Name: enchantment_types_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.enchantment_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.enchantment_types_id_seq OWNER TO bukiya_user;

--
-- Name: enchantment_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.enchantment_types_id_seq OWNED BY public.enchantment_types.id;


--
-- Name: idle_bonus_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.idle_bonus_masters (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    multiplier double precision,
    duration_seconds integer,
    icon_name character varying,
    bonus_type character varying,
    is_active boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.idle_bonus_masters OWNER TO bukiya_user;

--
-- Name: idle_upgrade_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.idle_upgrade_masters (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    base_cost integer NOT NULL,
    income_multiplier double precision,
    max_level integer,
    icon_name character varying,
    unlock_level integer,
    is_active boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.idle_upgrade_masters OWNER TO bukiya_user;

--
-- Name: material_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.material_masters (
    name character varying(100) NOT NULL,
    category character varying(20),
    rarity_id character varying(20) NOT NULL,
    description text,
    base_price integer NOT NULL,
    price_volatility numeric(3,2) DEFAULT 0.1,
    stack_size integer DEFAULT 999,
    emoji character varying(10),
    color_code character varying(7),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    id integer NOT NULL
);


ALTER TABLE public.material_masters OWNER TO bukiya_user;

--
-- Name: material_targeting_setups; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.material_targeting_setups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    setup_name character varying(100) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.material_targeting_setups OWNER TO bukiya_user;

--
-- Name: mission_progress_logs; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.mission_progress_logs (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    mission_id uuid NOT NULL,
    action_type character varying(50) NOT NULL,
    progress_delta integer NOT NULL,
    extra_data character varying(500),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mission_progress_logs OWNER TO bukiya_user;

--
-- Name: COLUMN mission_progress_logs.player_id; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.player_id IS 'プレイヤーID';


--
-- Name: COLUMN mission_progress_logs.mission_id; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.mission_id IS 'プレイヤーミッションID';


--
-- Name: COLUMN mission_progress_logs.action_type; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.action_type IS 'アクションタイプ';


--
-- Name: COLUMN mission_progress_logs.progress_delta; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.progress_delta IS '進捗増加量';


--
-- Name: COLUMN mission_progress_logs.extra_data; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.extra_data IS '追加情報（JSON文字列）';


--
-- Name: COLUMN mission_progress_logs.created_at; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.mission_progress_logs.created_at IS '作成日時';


--
-- Name: mission_progress_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.mission_progress_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mission_progress_logs_id_seq OWNER TO bukiya_user;

--
-- Name: mission_progress_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.mission_progress_logs_id_seq OWNED BY public.mission_progress_logs.id;


--
-- Name: mission_templates; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.mission_templates (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    mission_type character varying(50) NOT NULL,
    target_type character varying(50) NOT NULL,
    target_count integer DEFAULT 1 NOT NULL,
    target_conditions json,
    reward_gold integer DEFAULT 0,
    reward_exp integer DEFAULT 0,
    reward_items json,
    is_active boolean DEFAULT true,
    reset_schedule character varying(20) DEFAULT 'daily'::character varying,
    required_level integer DEFAULT 1,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.mission_templates OWNER TO bukiya_user;

--
-- Name: mission_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.mission_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mission_templates_id_seq OWNER TO bukiya_user;

--
-- Name: mission_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.mission_templates_id_seq OWNED BY public.mission_templates.id;


--
-- Name: monster_drop_tables; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.monster_drop_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    monster_master_id character varying(50) NOT NULL,
    drop_type character varying(20) NOT NULL,
    drop_target_id character varying(50),
    quantity_min integer DEFAULT 1,
    quantity_max integer DEFAULT 1,
    drop_rate numeric(5,4) NOT NULL,
    required_weapon_type character varying(20),
    bonus_rate numeric(5,4) DEFAULT 0.0000,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT drop_tables_quantity_check CHECK ((quantity_max >= quantity_min)),
    CONSTRAINT drop_tables_rate_check CHECK (((drop_rate >= (0)::numeric) AND (drop_rate <= (1)::numeric)))
);


ALTER TABLE public.monster_drop_tables OWNER TO bukiya_user;

--
-- Name: monster_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.monster_masters (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    hp integer NOT NULL,
    attack integer NOT NULL,
    defense integer NOT NULL,
    speed integer DEFAULT 100,
    attribute_id character varying(20),
    resistances jsonb DEFAULT '{}'::jsonb,
    weaknesses text[],
    immunities text[],
    level_min integer NOT NULL,
    level_max integer NOT NULL,
    base_success_rate numeric(5,4) DEFAULT 0.7000,
    emoji character varying(10),
    description text,
    area_id character varying(30) NOT NULL,
    spawn_rate numeric(5,4) DEFAULT 0.1000,
    is_active boolean DEFAULT true,
    is_boss boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    monster_type character varying(50),
    level integer DEFAULT 1,
    element character varying(50),
    weakness character varying(50),
    resistance character varying(50),
    spawn_areas character varying(255),
    spawn_weight integer DEFAULT 100,
    min_required_weapon_level integer DEFAULT 0,
    base_gold_reward integer DEFAULT 100,
    experience_reward integer DEFAULT 50,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT monster_masters_attack_check CHECK ((attack > 0)),
    CONSTRAINT monster_masters_defense_check CHECK ((defense >= 0)),
    CONSTRAINT monster_masters_hp_check CHECK ((hp > 0)),
    CONSTRAINT monster_masters_level_check CHECK ((level_max >= level_min))
);


ALTER TABLE public.monster_masters OWNER TO bukiya_user;

--
-- Name: player_adventurer_relationships; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_adventurer_relationships (
    player_id uuid NOT NULL,
    adventurer_master_id character varying(50) NOT NULL,
    trust_level integer DEFAULT 0,
    total_trades integer DEFAULT 0,
    successful_expeditions integer DEFAULT 0,
    failed_expeditions integer DEFAULT 0,
    total_gold_traded bigint DEFAULT 0,
    best_deal_margin integer DEFAULT 0,
    first_met_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_interaction_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT player_adventurer_relationships_trust_level_check CHECK (((trust_level >= 0) AND (trust_level <= 100)))
);


ALTER TABLE public.player_adventurer_relationships OWNER TO bukiya_user;

--
-- Name: player_character_bonds; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_character_bonds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    character_id integer NOT NULL,
    trust_level integer DEFAULT 0 NOT NULL,
    friendship_level integer DEFAULT 1 NOT NULL,
    total_trust_points integer DEFAULT 0,
    total_interactions integer DEFAULT 0,
    total_weapon_gifts integer DEFAULT 0,
    total_quests_together integer DEFAULT 0,
    total_dragon_battles integer DEFAULT 0,
    current_level integer DEFAULT 1,
    current_experience integer DEFAULT 0,
    is_unlocked boolean DEFAULT false,
    is_favorited boolean DEFAULT false,
    equipped_weapon_id uuid,
    custom_nickname character varying(50),
    conversation_flags jsonb DEFAULT '{}'::jsonb,
    story_progress jsonb DEFAULT '{}'::jsonb,
    special_events jsonb DEFAULT '[]'::jsonb,
    unlock_date timestamp with time zone,
    last_interaction_at timestamp with time zone,
    last_level_up_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.player_character_bonds OWNER TO bukiya_user;

--
-- Name: player_enchantment_materials; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_enchantment_materials (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    material_id integer NOT NULL,
    quantity integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.player_enchantment_materials OWNER TO bukiya_user;

--
-- Name: COLUMN player_enchantment_materials.quantity; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.player_enchantment_materials.quantity IS '所持数';


--
-- Name: player_enchantment_materials_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.player_enchantment_materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_enchantment_materials_id_seq OWNER TO bukiya_user;

--
-- Name: player_enchantment_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.player_enchantment_materials_id_seq OWNED BY public.player_enchantment_materials.id;


--
-- Name: player_idle_bonuses; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_idle_bonuses (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    idle_system_id integer NOT NULL,
    bonus_id character varying NOT NULL,
    start_time timestamp without time zone,
    created_at timestamp without time zone
);


ALTER TABLE public.player_idle_bonuses OWNER TO bukiya_user;

--
-- Name: player_idle_bonuses_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.player_idle_bonuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_idle_bonuses_id_seq OWNER TO bukiya_user;

--
-- Name: player_idle_bonuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.player_idle_bonuses_id_seq OWNED BY public.player_idle_bonuses.id;


--
-- Name: player_idle_systems; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_idle_systems (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    base_income_per_second integer,
    current_level integer,
    upgrade_count integer,
    multiplier double precision,
    last_collected_at timestamp without time zone,
    experience integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.player_idle_systems OWNER TO bukiya_user;

--
-- Name: player_idle_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.player_idle_systems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_idle_systems_id_seq OWNER TO bukiya_user;

--
-- Name: player_idle_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.player_idle_systems_id_seq OWNED BY public.player_idle_systems.id;


--
-- Name: player_idle_upgrades; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_idle_upgrades (
    id integer NOT NULL,
    player_id uuid NOT NULL,
    idle_system_id integer NOT NULL,
    upgrade_id character varying NOT NULL,
    level integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.player_idle_upgrades OWNER TO bukiya_user;

--
-- Name: player_idle_upgrades_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.player_idle_upgrades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_idle_upgrades_id_seq OWNER TO bukiya_user;

--
-- Name: player_idle_upgrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.player_idle_upgrades_id_seq OWNED BY public.player_idle_upgrades.id;


--
-- Name: player_materials; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_materials (
    player_id uuid NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    total_acquired integer DEFAULT 0,
    total_used integer DEFAULT 0,
    last_acquired_at timestamp with time zone,
    material_id character varying(50),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    material_master_id integer,
    CONSTRAINT player_materials_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.player_materials OWNER TO bukiya_user;

--
-- Name: player_missions; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_missions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    mission_template_id integer NOT NULL,
    current_progress integer DEFAULT 0,
    is_completed boolean DEFAULT false,
    is_claimed boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    claimed_at timestamp with time zone,
    expires_at timestamp with time zone
);


ALTER TABLE public.player_missions OWNER TO bukiya_user;

--
-- Name: player_statistics; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_statistics (
    player_id uuid NOT NULL,
    total_play_time_seconds bigint DEFAULT 0,
    session_count integer DEFAULT 0,
    last_session_duration integer DEFAULT 0,
    total_gold_earned bigint DEFAULT 0,
    total_gold_spent bigint DEFAULT 0,
    total_gems_purchased integer DEFAULT 0,
    total_gems_spent integer DEFAULT 0,
    weapons_crafted integer DEFAULT 0,
    enchants_attempted integer DEFAULT 0,
    enchants_succeeded integer DEFAULT 0,
    trades_completed integer DEFAULT 0,
    expeditions_sent integer DEFAULT 0,
    highest_weapon_attack integer DEFAULT 0,
    highest_enchant_level integer DEFAULT 0,
    max_daily_gold integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.player_statistics OWNER TO bukiya_user;

--
-- Name: player_weapons; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.player_weapons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    base_attack integer NOT NULL,
    enchant_level integer DEFAULT 0,
    current_durability integer DEFAULT 100,
    max_durability integer DEFAULT 100,
    abilities jsonb DEFAULT '[]'::jsonb,
    custom_name character varying(100),
    is_favorite boolean DEFAULT false,
    acquired_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_used_at timestamp with time zone,
    is_equipped boolean DEFAULT false,
    is_locked boolean DEFAULT false,
    attack integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    weapon_master_id integer,
    CONSTRAINT player_weapons_current_durability_check CHECK ((current_durability >= 0)),
    CONSTRAINT player_weapons_durability_check CHECK ((current_durability <= max_durability)),
    CONSTRAINT player_weapons_enchant_level_check CHECK ((enchant_level >= 0)),
    CONSTRAINT player_weapons_max_durability_check CHECK ((max_durability > 0))
);


ALTER TABLE public.player_weapons OWNER TO bukiya_user;

--
-- Name: players; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.players (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    gold bigint DEFAULT 1000,
    gems integer DEFAULT 50,
    shop_level integer DEFAULT 1,
    reputation integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    is_banned boolean DEFAULT false,
    ban_reason text,
    shop_exp integer DEFAULT 0 NOT NULL,
    idle_income_rate integer DEFAULT 10 NOT NULL,
    idle_income_multiplier integer DEFAULT 100 NOT NULL,
    last_idle_collection_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_visitor_spawn_time timestamp with time zone,
    banned_at timestamp with time zone,
    ban_expires_at timestamp with time zone,
    CONSTRAINT players_email_check CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT players_gems_check CHECK ((gems >= 0)),
    CONSTRAINT players_gold_check CHECK ((gold >= 0)),
    CONSTRAINT players_idle_income_multiplier_check CHECK ((idle_income_multiplier >= 1)),
    CONSTRAINT players_idle_income_rate_check CHECK ((idle_income_rate >= 0)),
    CONSTRAINT players_reputation_check CHECK ((reputation >= 0)),
    CONSTRAINT players_shop_exp_check CHECK ((shop_exp >= 0)),
    CONSTRAINT players_shop_level_check CHECK ((shop_level >= 1)),
    CONSTRAINT players_username_check CHECK ((length((username)::text) >= 3))
);


ALTER TABLE public.players OWNER TO bukiya_user;

--
-- Name: quest_area_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.quest_area_masters (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    area_type character varying(50) NOT NULL,
    difficulty integer DEFAULT 1 NOT NULL,
    required_level integer DEFAULT 1 NOT NULL,
    duration_minutes integer DEFAULT 60 NOT NULL,
    image_url character varying(255),
    background_color character varying(7) DEFAULT '#4CAF50'::character varying NOT NULL,
    description text,
    unlock_condition character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.quest_area_masters OWNER TO bukiya_user;

--
-- Name: quest_area_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.quest_area_masters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quest_area_masters_id_seq OWNER TO bukiya_user;

--
-- Name: quest_area_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.quest_area_masters_id_seq OWNED BY public.quest_area_masters.id;


--
-- Name: quest_rewards; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.quest_rewards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    adventurer_quest_id uuid NOT NULL,
    item_type character varying(20) NOT NULL,
    item_id character varying(50) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    buyback_price integer,
    buyback_deadline timestamp with time zone,
    is_bought boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.quest_rewards OWNER TO bukiya_user;

--
-- Name: rarity_levels; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.rarity_levels (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL,
    level integer NOT NULL,
    color_code character varying(7),
    star_display character varying(10),
    attack_multiplier numeric(3,2) DEFAULT 1.00,
    max_enchant_level integer DEFAULT 10,
    ability_slots integer DEFAULT 0,
    base_drop_rate numeric(6,4) DEFAULT 0.6000,
    price_multiplier numeric(3,2) DEFAULT 1.00,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.rarity_levels OWNER TO bukiya_user;

--
-- Name: recipe_materials; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.recipe_materials (
    recipe_id integer NOT NULL,
    quantity integer NOT NULL,
    material_id integer,
    CONSTRAINT recipe_materials_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.recipe_materials OWNER TO bukiya_user;

--
-- Name: season_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.season_masters (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    start_date date NOT NULL,
    end_date date,
    display_order integer NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.season_masters OWNER TO bukiya_user;

--
-- Name: COLUMN season_masters.name; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.name IS 'シーズン名';


--
-- Name: COLUMN season_masters.description; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.description IS 'シーズンの説明';


--
-- Name: COLUMN season_masters.start_date; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.start_date IS '開始日';


--
-- Name: COLUMN season_masters.end_date; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.end_date IS '終了日';


--
-- Name: COLUMN season_masters.display_order; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.display_order IS '表示順序';


--
-- Name: COLUMN season_masters.is_active; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.is_active IS '有効フラグ';


--
-- Name: COLUMN season_masters.created_at; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.created_at IS '作成日時';


--
-- Name: COLUMN season_masters.updated_at; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.season_masters.updated_at IS '更新日時';


--
-- Name: season_masters_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.season_masters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.season_masters_id_seq OWNER TO bukiya_user;

--
-- Name: season_masters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.season_masters_id_seq OWNED BY public.season_masters.id;


--
-- Name: targeting_material_weights; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.targeting_material_weights (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    setup_id uuid NOT NULL,
    material_id character varying NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL,
    priority integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.targeting_material_weights OWNER TO bukiya_user;

--
-- Name: trade_logs; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.trade_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    trade_type character varying(50) NOT NULL,
    counterpart_type character varying(50) NOT NULL,
    counterpart_id character varying(50),
    gold_amount integer NOT NULL,
    gems_amount integer DEFAULT 0,
    items_given jsonb DEFAULT '[]'::jsonb,
    items_received jsonb DEFAULT '[]'::jsonb,
    success boolean DEFAULT true,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.trade_logs OWNER TO bukiya_user;

--
-- Name: weapon_enchantments; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.weapon_enchantments (
    id integer NOT NULL,
    weapon_id uuid NOT NULL,
    enchantment_type_id integer NOT NULL,
    level integer,
    success_count integer,
    failure_count integer,
    total_cost integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.weapon_enchantments OWNER TO bukiya_user;

--
-- Name: COLUMN weapon_enchantments.level; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.weapon_enchantments.level IS 'エンチャントレベル';


--
-- Name: COLUMN weapon_enchantments.success_count; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.weapon_enchantments.success_count IS '成功回数';


--
-- Name: COLUMN weapon_enchantments.failure_count; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.weapon_enchantments.failure_count IS '失敗回数';


--
-- Name: COLUMN weapon_enchantments.total_cost; Type: COMMENT; Schema: public; Owner: bukiya_user
--

COMMENT ON COLUMN public.weapon_enchantments.total_cost IS '総コスト';


--
-- Name: weapon_enchantments_id_seq; Type: SEQUENCE; Schema: public; Owner: bukiya_user
--

CREATE SEQUENCE public.weapon_enchantments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.weapon_enchantments_id_seq OWNER TO bukiya_user;

--
-- Name: weapon_enchantments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bukiya_user
--

ALTER SEQUENCE public.weapon_enchantments_id_seq OWNED BY public.weapon_enchantments.id;


--
-- Name: weapon_master_abilities; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.weapon_master_abilities (
    weapon_master_id character varying(50) NOT NULL,
    ability_id character varying(50) NOT NULL,
    slot_number integer NOT NULL,
    probability numeric(5,4) DEFAULT 1.0000,
    CONSTRAINT weapon_master_abilities_slot_number_check CHECK ((slot_number >= 1))
);


ALTER TABLE public.weapon_master_abilities OWNER TO bukiya_user;

--
-- Name: weapon_masters; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.weapon_masters (
    name character varying(100) NOT NULL,
    weapon_type_id character varying(20) NOT NULL,
    rarity_id character varying(20) NOT NULL,
    base_attack_min integer NOT NULL,
    base_attack_max integer NOT NULL,
    base_price_min integer NOT NULL,
    base_price_max integer NOT NULL,
    crafting_time_minutes integer DEFAULT 30,
    required_shop_level integer DEFAULT 1,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    season_id integer,
    id integer NOT NULL,
    CONSTRAINT weapon_masters_base_attack_min_check CHECK ((base_attack_min > 0)),
    CONSTRAINT weapon_masters_check CHECK ((base_attack_max >= base_attack_min)),
    CONSTRAINT weapon_masters_check1 CHECK ((base_price_max >= base_price_min))
);


ALTER TABLE public.weapon_masters OWNER TO bukiya_user;

--
-- Name: weapon_types; Type: TABLE; Schema: public; Owner: bukiya_user
--

CREATE TABLE public.weapon_types (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL,
    emoji character varying(10),
    description text,
    base_multiplier numeric(4,2) DEFAULT 1.00,
    attack_speed_modifier numeric(4,2) DEFAULT 1.00,
    critical_rate_bonus integer DEFAULT 0,
    special_effect character varying(100),
    is_active boolean DEFAULT true,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone
);


ALTER TABLE public.weapon_types OWNER TO bukiya_user;

--
-- Name: adventurer_characters id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_characters ALTER COLUMN id SET DEFAULT nextval('public.adventurer_characters_id_seq'::regclass);


--
-- Name: crafting_recipes id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.crafting_recipes ALTER COLUMN id SET DEFAULT nextval('public.crafting_recipes_id_seq'::regclass);


--
-- Name: enchantment_logs id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_logs ALTER COLUMN id SET DEFAULT nextval('public.enchantment_logs_id_seq'::regclass);


--
-- Name: enchantment_materials id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_materials ALTER COLUMN id SET DEFAULT nextval('public.enchantment_materials_id_seq'::regclass);


--
-- Name: enchantment_types id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_types ALTER COLUMN id SET DEFAULT nextval('public.enchantment_types_id_seq'::regclass);


--
-- Name: mission_progress_logs id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_progress_logs ALTER COLUMN id SET DEFAULT nextval('public.mission_progress_logs_id_seq'::regclass);


--
-- Name: mission_templates id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_templates ALTER COLUMN id SET DEFAULT nextval('public.mission_templates_id_seq'::regclass);


--
-- Name: player_enchantment_materials id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_enchantment_materials ALTER COLUMN id SET DEFAULT nextval('public.player_enchantment_materials_id_seq'::regclass);


--
-- Name: player_idle_bonuses id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_bonuses ALTER COLUMN id SET DEFAULT nextval('public.player_idle_bonuses_id_seq'::regclass);


--
-- Name: player_idle_systems id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_systems ALTER COLUMN id SET DEFAULT nextval('public.player_idle_systems_id_seq'::regclass);


--
-- Name: player_idle_upgrades id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_upgrades ALTER COLUMN id SET DEFAULT nextval('public.player_idle_upgrades_id_seq'::regclass);


--
-- Name: quest_area_masters id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.quest_area_masters ALTER COLUMN id SET DEFAULT nextval('public.quest_area_masters_id_seq'::regclass);


--
-- Name: season_masters id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.season_masters ALTER COLUMN id SET DEFAULT nextval('public.season_masters_id_seq'::regclass);


--
-- Name: weapon_enchantments id; Type: DEFAULT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_enchantments ALTER COLUMN id SET DEFAULT nextval('public.weapon_enchantments_id_seq'::regclass);


--
-- Data for Name: abilities; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.abilities (id, name, description, effect_type, effect_value, effect_percentage, required_weapon_types, required_rarity_level, is_active, rarity, created_at) FROM stdin;
attack_boost_small	攻撃力上昇（小）	攻撃力を5%上昇させる	attack_bonus	5	t	{sword,bow,staff}	1	t	common	2025-06-11 22:48:29.630052+00
critical_boost	クリティカル率上昇	クリティカル率を10%上昇させる	critical_rate	10	t	{sword,bow}	2	t	rare	2025-06-11 22:48:29.630052+00
fire_damage	火炎ダメージ	攻撃時に追加火属性ダメージ	special_effect	25	f	{sword,staff}	2	t	rare	2025-06-11 22:48:29.630052+00
\.


--
-- Data for Name: active_processes; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.active_processes (id, player_id, process_type, status, started_at, duration_minutes, completed_at, process_data, result_data, rewards_claimed) FROM stdin;
\.


--
-- Data for Name: admin_logs; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.admin_logs (id, admin_user, action_type, target_type, target_id, old_values, new_values, reason, ip_address, session_id, created_at) FROM stdin;
\.


--
-- Data for Name: adventurer_characters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_characters (id, name, title, profession, rarity, base_level, max_level, max_trust_level, unlock_player_level, unlock_condition, base_stats, growth_rates, preferred_weapon_types, elemental_affinity, personality, backstory, quote, avatar_url, color_theme, voice_type, special_abilities, passive_skills, dragon_battle_eligible, leadership_bonus, team_synergy, is_story_character, unlock_order, is_limited_time, availability_start, availability_end, is_active, created_at, updated_at) FROM stdin;
6	アリス	見習い冒険者	warrior	common	1	50	100	1	\N	{"magic": 2, "speed": 6, "attack": 12, "defense": 8}	{"magic": 0.8, "speed": 1.0, "attack": 1.3, "defense": 1.2}	{sword,dagger}	\N	friendly	小さな村出身の少女。剣を握って間もないが、努力家で仲間想い。	みんなで一緒に頑張りましょう！	\N	#FF6B8A	\N	[{"name": "初心者の幸運", "description": "最初の武器強化が50%成功率アップ"}]	[{"name": "チームワーク", "description": "パーティ全体のモラル+10%"}]	f	5	{"エリー": 1.1, "リオン": 1.2}	t	1	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
7	リオン	若き射手	archer	common	2	55	100	3	\N	{"magic": 4, "speed": 12, "attack": 14, "defense": 6}	{"magic": 1.1, "speed": 1.4, "attack": 1.2, "defense": 1.0}	{bow}	wind	normal	森で育った青年。動物との対話ができ、風の魔法も少し扱える。	風よ、俺の矢を導け！	\N	#4CAF50	\N	[{"name": "精密射撃", "description": "クリティカル率+15%"}]	[{"name": "森の知識", "description": "素材収集時ボーナス+20%"}]	f	8	{"アリス": 1.2, "ガルド": 1.1}	t	2	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
8	エリー	魔法学徒	mage	rare	3	60	120	5	\N	{"magic": 18, "speed": 8, "attack": 6, "defense": 4}	{"magic": 1.5, "speed": 1.1, "attack": 0.8, "defense": 0.9}	{staff}	arcane	stingy	魔法学院の特待生。プライドが高いが、実力は確か。節約家。	魔法の真理を解き明かしてみせる！	\N	#9C27B0	\N	[{"name": "魔法増幅", "description": "魔法武器の威力+25%"}]	[{"name": "魔力節約", "description": "魔法使用時のマナ消費-20%"}]	t	12	{"アリス": 1.1, "セレナ": 1.3}	t	3	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
9	ガルド	歴戦の戦士	warrior	rare	15	70	150	10	\N	{"magic": 3, "speed": 8, "attack": 22, "defense": 18}	{"magic": 0.7, "speed": 0.9, "attack": 1.4, "defense": 1.3}	{sword,hammer}	earth	generous	数々の戦場を生き抜いた歴戦の戦士。若い冒険者たちの良き師。	俺の背中を見て学べ！	\N	#795548	\N	[{"name": "戦場経験", "description": "HPが50%以下で攻撃力+30%"}]	[{"name": "指導者", "description": "パーティの経験値獲得+15%"}]	t	15	{"アリス": 1.3, "リオン": 1.2}	t	4	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
10	セレナ	賢者	mage	epic	25	80	200	15	\N	{"magic": 28, "speed": 12, "attack": 8, "defense": 10}	{"magic": 1.6, "speed": 1.2, "attack": 0.9, "defense": 1.1}	{staff}	light	wealthy	古代魔法の研究者。豊富な知識と財力を持つ神秘的な女性。	知識こそが真の力よ	\N	#FFD700	\N	[{"name": "古代魔法", "description": "全属性魔法威力+40%"}]	[{"name": "賢者の知恵", "description": "アイテム鑑定成功率+50%"}]	t	20	{"全員": 1.1, "エリー": 1.4}	t	5	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
11	ルナ	月の踊り子	rogue	rare	8	60	120	8	\N	{"magic": 6, "speed": 18, "attack": 16, "defense": 8}	{"magic": 1.2, "speed": 1.5, "attack": 1.3, "defense": 1.0}	{dagger}	dark	mysterious	月明かりの下で舞うように戦う謎多き盗賊。	月影に踊り、敵を翻弄する	\N	#6A1B9A	\N	[{"name": "影分身", "description": "回避率+25%"}]	[{"name": "夜行性", "description": "夜間戦闘で全能力+20%"}]	f	10	{"アリス": 1.1}	f	6	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
12	ブレイク	鋼鉄の盾	paladin	rare	12	65	130	12	\N	{"magic": 8, "speed": 4, "attack": 14, "defense": 24}	{"magic": 1.2, "speed": 0.8, "attack": 1.1, "defense": 1.5}	{sword,hammer}	light	loyal	正義を愛する聖騎士。仲間を守ることに命をかける。	この盾がある限り、誰も傷つけさせない	\N	#03A9F4	\N	[{"name": "聖なる守護", "description": "パーティのダメージ軽減+20%"}]	[{"name": "不屈の意志", "description": "状態異常耐性+50%"}]	t	18	{"全員": 1.05, "ガルド": 1.2}	f	7	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
13	フィア	炎の精霊使い	mage	epic	18	75	160	18	\N	{"magic": 26, "speed": 14, "attack": 10, "defense": 8}	{"magic": 1.5, "speed": 1.3, "attack": 1.0, "defense": 1.0}	{staff}	fire	passionate	炎の精霊と契約した情熱的な魔法使い。	我が炎で全てを焼き尽くす！	\N	#FF5722	\N	[{"name": "炎の化身", "description": "火属性魔法威力+60%"}]	[{"name": "熱血", "description": "クリティカル時に追加炎ダメージ"}]	t	22	{"エリー": 1.1, "セレナ": 1.2}	f	8	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
14	アイス	氷雪の射手	archer	epic	20	75	150	20	\N	{"magic": 12, "speed": 16, "attack": 20, "defense": 10}	{"magic": 1.2, "speed": 1.3, "attack": 1.4, "defense": 1.1}	{bow}	ice	cool	極北から来た冷静沈着な弓使い。氷の魔法も操る。	氷点下の精密さで仕留める	\N	#00BCD4	\N	[{"name": "氷結射撃", "description": "攻撃時30%で敵を凍結"}]	[{"name": "冷静沈着", "description": "常に冷静、混乱耐性100%"}]	t	25	{"フィア": 0.8, "リオン": 1.3}	f	9	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
15	ドラン	竜の血を引く者	warrior	legendary	30	90	250	25	\N	{"magic": 16, "speed": 12, "attack": 32, "defense": 22}	{"magic": 1.3, "speed": 1.1, "attack": 1.5, "defense": 1.3}	{sword}	dragon	noble	古き竜族の血を引く高貴な戦士。真の力はまだ目覚めていない。	竜の誇りにかけて！	\N	#D32F2F	\N	[{"name": "竜の怒り", "description": "HP低下で攻撃力倍増"}]	[{"name": "竜鱗", "description": "物理ダメージ軽減30%"}]	t	50	{"全員": 1.2, "ガルド": 1.4}	f	10	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
16	ミスティ	時の魔女	mage	legendary	35	95	300	30	\N	{"magic": 40, "speed": 20, "attack": 12, "defense": 16}	{"magic": 1.8, "speed": 1.4, "attack": 1.0, "defense": 1.2}	{staff}	time	enigmatic	時間を操る禁断の魔法を研究する謎の魔女。	時よ、私の意のままに	\N	#9E9E9E	\N	[{"name": "時間操作", "description": "ターン順操作可能"}]	[{"name": "予知", "description": "敵の攻撃を50%で回避"}]	t	80	{"エリー": 1.3, "セレナ": 1.5}	f	11	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
17	サンダー	雷神の使い	archer	legendary	32	90	280	28	\N	{"magic": 18, "speed": 24, "attack": 28, "defense": 14}	{"magic": 1.4, "speed": 1.5, "attack": 1.5, "defense": 1.1}	{bow}	thunder	wild	雷神に選ばれし者。雷の矢で敵を貫く。	雷鳴よ、我が矢と共に！	\N	#FFEB3B	\N	[{"name": "雷神の矢", "description": "攻撃時全敵にダメージ"}]	[{"name": "電撃耐性", "description": "雷属性ダメージ無効"}]	t	70	{"アイス": 1.2, "リオン": 1.4}	f	12	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
18	シャドウ	影の暗殺者	rogue	legendary	28	85	200	25	\N	{"magic": 10, "speed": 32, "attack": 30, "defense": 8}	{"magic": 1.2, "speed": 1.7, "attack": 1.6, "defense": 0.9}	{dagger}	shadow	silent	完璧な暗殺技術を持つ影の一族の末裔。	...	\N	#424242	\N	[{"name": "一撃必殺", "description": "低確率で即死攻撃"}]	[{"name": "透明化", "description": "戦闘開始時しばらく無敵"}]	t	60	{"ルナ": 1.5}	f	13	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
19	オーロラ	光の聖女	paladin	legendary	26	85	350	22	\N	{"magic": 30, "speed": 14, "attack": 16, "defense": 20}	{"magic": 1.6, "speed": 1.2, "attack": 1.2, "defense": 1.4}	{staff,sword}	holy	compassionate	女神の加護を受けた聖女。全ての生命を愛する。	光よ、迷える魂を導きたまえ	\N	#FFFFFF	\N	[{"name": "神聖治癒", "description": "戦闘後パーティ全回復"}]	[{"name": "聖なる加護", "description": "パーティの全耐性+25%"}]	t	100	{"全員": 1.3}	f	14	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
20	ヴォイド	虚無の王	warrior	legendary	40	100	500	35	\N	{"magic": 25, "speed": 18, "attack": 45, "defense": 30}	{"magic": 1.5, "speed": 1.3, "attack": 1.8, "defense": 1.5}	{sword}	void	transcendent	全てを無に帰す力を持つ超越者。真の最終ボス級の存在。	虚無こそが真理...	\N	#000000	\N	[{"name": "虚無の剣", "description": "防御無視攻撃"}]	[{"name": "超越", "description": "全状態異常無効"}]	t	200	{}	f	15	f	\N	\N	t	2025-06-13 00:37:36.803428+00	2025-06-13 00:37:36.803428+00
\.


--
-- Data for Name: adventurer_instances; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_instances (id, adventurer_master_id, player_id, name, level, trust_level, status, current_quest_id, visit_start_time, visit_end_time, is_named_character, character_id, generic_name, created_at, updated_at) FROM stdin;
d9641fe5-37c9-4ea2-9be9-6b90486de09d	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_548	8	30	returning	\N	\N	\N	f	\N	\N	2025-06-13 03:08:20.962539+00	2025-06-13 08:57:24.420423+00
d4b7b184-c132-4b33-82e0-34cdafb9cc3a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_799	7	51	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:04:14.23512+00	2025-06-13 09:11:11.069914+00
25a6533e-f3f3-4e38-b10f-355af8257d79	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_193	7	19	returning	\N	\N	\N	f	\N	\N	2025-06-13 03:08:20.962539+00	2025-06-13 08:57:24.541487+00
83dc02f4-d469-4085-acf0-022929858bd5	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_995	9	35	returning	\N	\N	\N	f	\N	\N	2025-06-13 03:08:20.962539+00	2025-06-13 08:57:24.585394+00
05b537cd-3839-48df-a071-33b6c8552f49	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_561	8	26	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:23:37.188158+00	2025-06-13 08:57:24.628389+00
c0564312-8670-45b4-99bd-072eaf075765	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_266	7	37	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:30:14.491806+00	2025-06-13 08:57:24.669222+00
b0ec7fbe-c8be-488c-b790-36017e75ff2b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_730	7	53	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:04:14.23512+00	2025-06-13 09:04:41.11837+00
17e31039-8b29-4603-bf24-cf08d962b8f2	1	\N	村の少年タム_397	7	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:53:45.537933+00	2025-06-13 14:52:11.046295+00
e844bcdf-afa5-4a1c-a7b1-b36bd23d0e0f	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_146	5	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 00:30:56.357167+00	2025-06-13 02:40:21.308768+00
0244a5b2-4534-4daf-b94a-dff197621446	1	\N	村の少年タム_556	4	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:54:45.444036+00	2025-06-13 15:00:10.92974+00
1ec7f7ff-e6b1-4880-ba2a-645e2b02041b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_653	4	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 01:32:39.434959+00	2025-06-13 03:35:09.15115+00
79fd2cd5-da09-4528-803c-a1109d4e3655	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_490	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 02:02:09.550514+00	2025-06-13 03:43:38.883196+00
0e319c29-1d8e-424b-93d9-e529e90c5d7c	1	\N	村の少年タム_664	7	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:53:45.537933+00	2025-06-13 15:20:03.900056+00
05a213e3-8dd5-4e10-a134-37c58f9ef130	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_628	5	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 02:44:51.419113+00	2025-06-13 04:04:12.059424+00
3744e847-3d57-4bc1-9ccd-6871ac0561cc	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_418	6	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 02:02:09.550514+00	2025-06-13 04:07:09.974977+00
36fbac44-3cbb-4b18-bedb-dbeaf1b3470b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_739	4	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 02:02:09.550514+00	2025-06-13 04:10:10.310411+00
5cbdcaa5-9744-4063-9ada-86543ee58ad7	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_69	5	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:15:58.920082+00	2025-06-13 04:32:13.806554+00
494a85cc-0e2a-49a5-96c1-1171583a326a	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_512	9	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:35:42.040449+00	2025-06-13 04:36:50.119929+00
2353f2ba-ea33-4636-93b1-cdc5c3c0df46	\N	119e86b2-8d18-467c-a6da-09df465a01de	見習い冒険者 アリス	1	50	idle	\N	\N	\N	t	6	\N	2025-06-13 03:15:58.920082+00	2025-06-13 04:48:26.656766+00
a6751e6c-39fe-459d-9060-4d57e0dee549	3	ce0b1337-753c-45fd-ab5a-473b0d10c736	魔法学校の生徒リオ_86	6	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:31:23.053001+00	2025-06-13 04:55:26.673482+00
b3993cb5-795b-43fd-90c6-f07c7b389463	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_240	7	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:17:08.265479+00	2025-06-13 05:04:30.032439+00
487116cf-7730-4537-b5e2-2ae5c19ace10	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_257	3	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:03:14.279199+00	2025-06-13 05:10:39.782406+00
d88c2cab-f1ba-475d-bfcf-a127e197f358	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_271	5	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:56:06.440035+00	2025-06-13 05:15:10.001351+00
7fef9f17-5823-4243-9f79-89c483fb583c	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_132	9	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:34:51.723429+00	2025-06-13 05:18:09.743895+00
3eff4c88-d2a0-4b1f-8c71-f4be62e7f476	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_257	5	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:37.188158+00	2025-06-13 05:18:39.742137+00
3b1f037a-6432-4345-a300-6972e052cbe6	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_827	8	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:17:08.265479+00	2025-06-13 05:19:09.732882+00
93b69f65-7370-47c1-945d-e89d599982b0	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_398	8	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:31:23.053001+00	2025-06-13 05:28:39.726835+00
2dbf16ed-1fc1-4f30-bbc5-318041eacbc8	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_121	4	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:08.531406+00	2025-06-13 05:31:09.768782+00
f643fe4a-c860-4dde-aba5-548f4744d061	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_347	8	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:53:59.228525+00	2025-06-13 05:32:09.748897+00
7d454b2f-af60-4f05-b25f-3434b061ce85	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_3	4	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:08.531406+00	2025-06-13 05:35:06.246555+00
23cded0b-88f4-4d76-b192-ecf7dbc77ae2	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_492	8	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:14.491806+00	2025-06-13 05:39:34.518536+00
2fe606cc-d51b-4e2e-be20-1530e0b9ac17	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_895	4	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:55:46.667605+00	2025-06-13 05:40:04.825246+00
9b1ba7ce-0944-420e-aaea-f1552c8436a1	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_392	7	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:55:46.667605+00	2025-06-13 05:46:53.91743+00
31e58594-ede1-4a05-8efd-0f021e6b9869	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_403	4	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:14.491806+00	2025-06-13 05:47:23.936196+00
c1621ced-01f2-4ef5-9fc4-0c814a86ea90	3	ce0b1337-753c-45fd-ab5a-473b0d10c736	魔法学校の生徒リオ_975	7	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:34:51.723429+00	2025-06-13 05:51:53.946644+00
9b935d66-54fd-4465-8e6f-fd74bd725545	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_354	7	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:37.188158+00	2025-06-13 05:55:53.954864+00
0492cfbd-a3eb-4164-b665-85904a885310	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_771	3	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:35:42.040449+00	2025-06-13 06:04:43.120378+00
3697ecd9-0b3a-4376-bcbe-0289a5e37a58	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_91	10	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:37.188158+00	2025-06-13 06:04:43.120378+00
f72b533b-ddb2-4326-b3bc-c77d008e2635	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_631	4	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:56:06.440035+00	2025-06-13 06:04:43.120378+00
b2088bbf-68f5-40aa-bbd3-cfae3b6ed53c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_293	6	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:15:58.920082+00	2025-06-13 06:13:08.745403+00
e64d44c7-86cc-41a4-89d1-735969538cdb	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_179	8	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:53:59.228525+00	2025-06-13 06:15:16.233204+00
3d115f7d-b569-413e-9216-f70e32301e04	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_863	3	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:56:06.440035+00	2025-06-13 06:17:18.658965+00
741e5ff6-e849-4716-8086-7cb9d5761c6c	3	ce0b1337-753c-45fd-ab5a-473b0d10c736	魔法学校の生徒リオ_683	5	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:31:23.053001+00	2025-06-13 06:21:48.965865+00
aeb5e649-af34-4285-9b41-b72697de19fe	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_860	8	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:08.531406+00	2025-06-13 06:25:18.94322+00
114b0832-c04a-4712-9408-3765177c90f9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_618	6	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:53:59.228525+00	2025-06-13 06:26:18.693372+00
51226919-9498-424e-94b7-314ec3c19c4a	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_344	5	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:35:42.040449+00	2025-06-13 06:27:48.68424+00
f32796e1-b9d1-4e34-b0bc-7932f92e86f2	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_839	8	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:13:59.074289+00	2025-06-13 06:32:24.740168+00
dcb65b43-b531-4244-886f-9d4ee1966b86	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_269	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:56:06.440035+00	2025-06-13 06:42:46.82754+00
61adb853-0294-46ed-86aa-a0220af308b0	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_37	3	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:13:59.074289+00	2025-06-13 07:13:13.236721+00
73cc60c0-600c-4905-b620-c78387cf23d1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_695	7	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:14.491806+00	2025-06-13 07:13:13.236721+00
9d893a81-8924-4c45-9b84-05dea1acd72b	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_120	4	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 03:56:06.440035+00	2025-06-13 07:13:13.236721+00
b35d51b7-1cbb-4878-b288-7bb7a7749f5b	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_292	8	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:13:59.074289+00	2025-06-13 07:13:13.236721+00
d36cac0d-9b74-4485-a793-d7dd090b5880	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_569	3	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:16.201778+00	2025-06-13 07:13:13.236721+00
d6ee773b-e0db-4c48-9139-c07ceb78156d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_78	10	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:01.959179+00	2025-06-13 07:13:13.236721+00
d96350e6-983e-47ad-ba8b-188127797bf9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_260	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:26.822321+00	2025-06-13 07:13:13.236721+00
ffbfa2ed-1197-4841-bc63-1d8598c7e5ab	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_60	5	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:43.898343+00	2025-06-13 07:17:42.133454+00
6b4fc65b-95c5-467d-b320-89add7311a69	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_656	10	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:14.491806+00	2025-06-13 07:19:32.831301+00
267773c8-ff9b-4cbd-8ba1-caf53936264b	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_410	8	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:23:08.531406+00	2025-06-13 07:21:13.986577+00
b5643976-1820-441d-93b7-865537660aac	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_357	7	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:13.927446+00	2025-06-13 05:26:39.734989+00
7eb27cda-3141-4f5c-aca7-01e977e75d6d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_710	7	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:44.055748+00	2025-06-13 05:31:09.768782+00
c3ae87e2-7d1c-45a5-96fa-2130d38a70c3	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_718	3	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:14.206779+00	2025-06-13 05:35:06.246555+00
fa99dfc5-09fe-481c-a259-a57d6a25283d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_639	4	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:13.951578+00	2025-06-13 05:35:06.246555+00
096efd18-6bd3-4e77-a746-ae933155d13a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_18	6	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:43.912078+00	2025-06-13 05:37:58.685974+00
e50c81b6-0082-4e75-8edb-a1912f8f187a	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_857	3	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:43.912078+00	2025-06-13 05:43:49.879827+00
cf5ec501-43a0-4614-85c6-aec41a0aeb05	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_226	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:43.937274+00	2025-06-13 05:50:53.916967+00
eeacc40b-cbf5-44ea-84d9-a0ea2c8cd6a9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_724	8	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:43.937274+00	2025-06-13 05:53:53.958699+00
387cc13c-1f9c-4680-a263-c8ae7b120527	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_567	4	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:14.206779+00	2025-06-13 06:04:43.120378+00
6751161d-7582-4ef7-a672-8df02cc097de	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_97	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:43.898343+00	2025-06-13 06:04:43.120378+00
73617d05-541e-4f6f-9c5a-35961360e715	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_84	7	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:44.654684+00	2025-06-13 06:04:43.120378+00
48629ae9-8d0c-4837-a660-0ab4c7f0adf1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_647	7	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:44.055748+00	2025-06-13 06:05:17.437084+00
8898206a-70ce-4426-b196-ea44547f0a66	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_257	4	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:44.055748+00	2025-06-13 06:07:12.95063+00
5d52f39b-a422-45db-b54d-321549319055	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_729	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:16.201778+00	2025-06-13 06:11:38.724075+00
d26e7ab6-f077-469b-b4dd-e78503a53fc4	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_184	6	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:13.951578+00	2025-06-13 06:13:38.752822+00
d8ef96e2-e5f5-447a-9993-173a2ada848a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_716	5	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:44.248767+00	2025-06-13 06:14:46.244978+00
9478daa6-9448-4f25-b530-1dc8e4913685	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_865	6	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:44.248767+00	2025-06-13 06:16:48.683674+00
478935d9-1f75-4707-af69-324c76ada51c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_774	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:43.898343+00	2025-06-13 06:19:48.929154+00
815ec805-5fca-4f9b-b95e-3a1f7b9d2f03	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_479	8	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:13.919317+00	2025-06-13 06:24:18.665801+00
7c1167c5-404e-48a3-9226-b19667ea4ec5	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_342	6	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:13.934877+00	2025-06-13 06:31:24.738912+00
cfc609bf-1687-47cf-8249-8ae47aa8e088	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_165	6	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:13.951578+00	2025-06-13 06:32:24.740168+00
0c5d018f-d472-4aa2-8d3f-d3f42d95f532	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_273	3	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:43.912078+00	2025-06-13 06:32:54.779117+00
de13c749-4f30-492c-83eb-d7ee5f1b9f8e	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_609	3	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:43.898343+00	2025-06-13 06:34:54.744074+00
a0955fce-8d36-4040-ad44-e5d91a466796	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_799	6	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:13.919317+00	2025-06-13 06:35:24.999344+00
38a57f4f-7846-448d-9fdf-63c936002ecd	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_597	5	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:44.654684+00	2025-06-13 06:36:54.768439+00
62b1db72-0152-4f99-a155-45f871ade112	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_978	8	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:13.919317+00	2025-06-13 06:42:46.82754+00
ffe16366-0e95-4ad2-8fdb-a10601ea0a4e	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_906	6	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:44.654684+00	2025-06-13 06:42:46.82754+00
0820dace-cf17-42e2-a10e-1ac43fa96c49	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_115	8	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:16.201778+00	2025-06-13 07:13:13.236721+00
18c33247-b91d-4618-8ac7-05734d97c906	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_648	8	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:44.654684+00	2025-06-13 07:13:13.236721+00
2d764028-2257-4943-a15e-f134663a29f0	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_676	9	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:14.206779+00	2025-06-13 07:13:13.236721+00
333e235d-ccc9-4a49-9f34-3462f251be8d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_239	8	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:16.201778+00	2025-06-13 07:13:13.236721+00
90d45278-1d1d-4850-b6ed-b4377d173595	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_537	7	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:30:43.898343+00	2025-06-13 07:13:13.236721+00
bab16334-1799-4e87-9889-d58065363539	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_91	4	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:50.289085+00	2025-06-13 07:13:13.236721+00
c87143b9-5192-455a-b03d-492d3b04ecdb	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_731	6	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:50.289085+00	2025-06-13 07:13:13.236721+00
7c330ff2-af5d-41e8-8522-6853d51df1de	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_43	7	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:13.927446+00	2025-06-13 07:17:42.133454+00
a46933a1-9838-4155-8e63-febba3cce45d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_808	7	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:13.934877+00	2025-06-13 07:17:42.133454+00
d8d0513c-f9ff-4eb2-b3fa-4e50276edb84	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_549	5	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:13.927446+00	2025-06-13 07:18:32.89166+00
ddda730f-7552-49d3-aee5-b9f8d124aa0f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_281	7	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:43.94235+00	2025-06-13 07:20:02.843082+00
1c1cac4a-c533-49f7-9b8f-9e28c4fd91af	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_396	7	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:44.654684+00	2025-06-13 07:21:02.821192+00
7825e6a6-1207-4019-91e6-0227c2ccc648	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_879	7	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:13.934877+00	2025-06-13 07:22:43.777335+00
0615bdb3-1586-41ff-96aa-7306b0e33003	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_574	4	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:13.919317+00	2025-06-13 07:26:33.626641+00
e82110e5-2f5f-4e99-8110-3668b2a0f0f1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_554	3	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:35:13.919317+00	2025-06-13 07:26:33.626641+00
fe378b49-60e7-4b18-ab45-0d351746c532	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_943	6	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:33:43.937274+00	2025-06-13 07:27:03.666227+00
da4e74db-69bc-4475-a659-1ffc979cfa15	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_856	6	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:13.951578+00	2025-06-13 07:27:33.638409+00
fabe59e1-8ae9-488a-9750-9d812afc7e03	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_644	6	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:43.94235+00	2025-06-13 07:32:03.704992+00
df11e8ae-aab7-4ecd-b78a-81a93d259383	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_119	5	34	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:43.912078+00	2025-06-13 07:34:45.995119+00
2064b96b-2d62-4eb8-9231-295143bf4f84	\N	119e86b2-8d18-467c-a6da-09df465a01de	見習い冒険者 アリス	1	55	returning	\N	\N	\N	t	6	\N	2025-06-13 08:11:10.333827+00	2025-06-13 08:57:24.688932+00
2c506b7a-3327-444e-ae92-88c167b48fa3	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_366	7	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:16:30.954058+00	2025-06-13 09:37:00.576555+00
8b247dae-8d98-4142-8cbf-147bef461785	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_724	4	44	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:11:10.333827+00	2025-06-13 09:03:11.101164+00
9349e2a4-bf5a-42ab-86fc-fc86fabe3d91	2	ce0b1337-753c-45fd-ab5a-473b0d10c736	見習い狩人サラ_576	7	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:16:30.954058+00	2025-06-13 09:17:41.42045+00
9ab2ff7d-f79a-4e5a-a98c-f778f7380862	1	ce0b1337-753c-45fd-ab5a-473b0d10c736	村の少年タム_590	3	36	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:16:30.954058+00	2025-06-13 09:33:49.558575+00
c5c150e3-f7e0-46cd-a496-4405ba300fcc	3	ce0b1337-753c-45fd-ab5a-473b0d10c736	魔法学校の生徒リオ_785	8	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:16:30.954058+00	2025-06-13 09:41:00.478555+00
c09f183d-9230-4175-a574-0a5f51b9631a	3	\N	魔法学校の生徒リオ_484	6	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:09.237548+00	2025-06-13 14:52:11.046295+00
e4e4ce66-8f35-43b9-a9fd-e8f94d3ddf6b	3	\N	魔法学校の生徒リオ_102	5	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:24:47.451111+00	2025-06-13 14:52:11.046295+00
9bf31c44-8849-41f8-90c7-d3235a562bef	1	\N	村の少年タム_292	7	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:02:45.440849+00	2025-06-13 15:02:10.938142+00
2bd04e33-ecd9-4c84-af60-79993492fcc2	1	\N	村の少年タム_75	7	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:02:45.440849+00	2025-06-13 15:35:03.85956+00
fb240520-97a6-452d-ab20-d24f4ba0dda5	2	\N	見習い狩人サラ_441	10	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:54:45.444036+00	2025-06-13 15:38:06.660165+00
ac499199-ec34-4b1b-91b9-1481d4a117c6	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_42	7	45	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:04:14.23512+00	2025-06-13 09:03:41.242753+00
520ce486-f4d5-48c5-a66e-f9dbe73d820c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_321	6	22	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:04:14.23512+00	2025-06-13 09:04:11.005259+00
9250a22d-3668-4b83-99c0-1a94cf713bee	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_70	7	44	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:34:15.667983+00	2025-06-13 12:27:14.482426+00
280d6a21-8155-478d-bdd9-54370049960d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_944	10	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:01.959179+00	2025-06-13 05:27:09.737494+00
c80c8bdc-f41c-44a7-8e24-71b5f9d58bb7	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_570	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:43.919403+00	2025-06-13 05:29:09.75135+00
36a9b629-a874-4bd9-aeec-de42ec32f816	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_460	5	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:43.898607+00	2025-06-13 05:30:09.772337+00
b338697c-63cf-4154-8cfd-a96c6db85f19	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_221	9	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:14.200141+00	2025-06-13 05:30:39.748727+00
216dfd14-bcb8-40f0-8ac8-a563b48f4698	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_848	4	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:43.919403+00	2025-06-13 05:32:09.748897+00
c15fd9bf-0b66-41e4-9b51-860f674b0ef8	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_259	6	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:43.919403+00	2025-06-13 05:35:06.246555+00
1fe90804-f35f-4eed-8d1a-9d37ffc8c8f9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_89	10	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:31.909496+00	2025-06-13 05:36:58.422818+00
69381ce2-3bf6-4cdf-94e4-a1881c5f3dc5	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_143	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:50.289085+00	2025-06-13 05:37:58.685974+00
090d4877-e73d-4858-a987-d31329cb92fd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_808	7	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:50.289085+00	2025-06-13 05:42:59.391091+00
d030ec5b-585a-4c79-8c43-539ac7832236	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_271	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:14.200141+00	2025-06-13 05:44:19.847212+00
d8ef4936-5760-4699-8830-9ee45f073cc8	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_383	7	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:45.826808+00	2025-06-13 05:47:53.903066+00
c963df34-7c5c-45ac-a8d2-d61d542b0b3a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_383	7	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:30.106607+00	2025-06-13 05:50:53.916967+00
7b4a0096-1c28-46f4-bb6f-a5875f2eddf1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_66	3	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:43.919403+00	2025-06-13 05:53:53.958699+00
1ac8f165-17e0-4089-bce6-3c1ad86fd62e	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_41	6	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:30.106607+00	2025-06-13 05:54:54.645875+00
4d2dce7c-9151-4e6f-914a-63f20dc7647b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_274	6	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:43.898607+00	2025-06-13 05:54:54.645875+00
5ef68eec-f44a-4415-acc5-c78ed456b378	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_320	10	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:31.925671+00	2025-06-13 05:54:54.645875+00
bdc7ea04-7ab7-441b-a392-65120db2a046	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_287	7	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:01.841584+00	2025-06-13 05:56:24.275187+00
1cc853b9-39c5-4138-9c00-1261e415aced	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_757	5	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:36:50.289085+00	2025-06-13 06:04:43.120378+00
3ea0995c-578b-45a9-828d-a17cb686a368	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_499	9	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:14.200141+00	2025-06-13 06:05:17.437084+00
c8fa356a-b0cd-4e2b-8c12-365299747213	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_640	5	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:31.925671+00	2025-06-13 06:10:38.764948+00
8c645644-2049-42a1-9ca0-4e521b1c84da	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_602	4	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:45.826808+00	2025-06-13 06:14:16.263497+00
7f470bfb-1b1a-4c18-827c-9137368b96b7	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_31	10	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:36.819306+00	2025-06-13 06:14:46.244978+00
d4bcc374-9c63-4c86-b725-61c5d28d164a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_528	8	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:43.898607+00	2025-06-13 06:14:46.244978+00
7759cc44-470b-458b-b7ae-33ad320cafe8	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_474	7	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:14.200141+00	2025-06-13 06:16:18.655392+00
38f83e6e-e682-43f1-aea1-d917c2f8c861	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_784	8	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:31.909496+00	2025-06-13 06:16:32.851913+00
7458a20a-34d3-4ff3-bde3-b5a20e1f7e49	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_430	10	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:13.874397+00	2025-06-13 06:20:18.666515+00
0f432004-65bd-4c07-8f62-8fd006f49826	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_90	10	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:01.959179+00	2025-06-13 06:24:18.665801+00
a71de161-379a-4a2e-b0c9-0b9b69331e4c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_991	6	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:14.200141+00	2025-06-13 06:24:18.665801+00
224761dc-56dc-4536-a3dd-ff92dcfdf4eb	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_900	7	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:31.909496+00	2025-06-13 06:37:36.166693+00
09e8569c-92a5-4345-a55d-65850e04a8ed	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_441	7	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:43.919403+00	2025-06-13 06:37:59.077236+00
290e2fa1-d3c6-4be6-a7ab-c4e5a28671fa	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_903	10	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:13.874397+00	2025-06-13 07:13:13.236721+00
36c607e3-341c-4c47-a272-7ad9015561d5	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_898	4	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:31.909496+00	2025-06-13 07:13:13.236721+00
399b1792-f718-4057-baa2-f2de1cc25046	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_972	5	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:43.898607+00	2025-06-13 07:13:13.236721+00
4fe528a5-5d63-4035-96b1-5758f4136b33	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_754	5	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:30.106607+00	2025-06-13 07:13:13.236721+00
57beea03-5c04-450c-9510-8d4d0eb5d6ea	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_679	6	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:45.826808+00	2025-06-13 07:13:13.236721+00
6bfbe7af-add1-48e0-b1ad-a00b5a0c79d2	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_799	10	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:45.826808+00	2025-06-13 07:13:13.236721+00
2d5c376b-ef37-4182-a24d-52121f0407ac	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_153	4	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:30.106607+00	2025-06-13 07:13:32.015137+00
a35e96e8-2210-42c2-ab72-425925f9d760	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_373	9	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:44.1654+00	2025-06-13 07:17:42.133454+00
628060f5-575f-4392-abf5-9c2df82508ae	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_668	6	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:13.918708+00	2025-06-13 07:20:32.844322+00
26010756-87be-4cd9-8f7b-3d54ab8044a2	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_807	4	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:44.1654+00	2025-06-13 07:26:03.655881+00
44544391-458f-4ec2-9f24-4f972650935e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_168	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:37:44.1654+00	2025-06-13 07:27:50.379606+00
6bb83cd7-e49d-47a2-a576-ada273129282	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_695	7	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:13.874397+00	2025-06-13 07:28:33.633003+00
39847d5e-b040-4ebe-b9e4-c1331270ca3b	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_946	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:01.959179+00	2025-06-13 07:29:03.646949+00
d6185d55-4be1-469d-b458-5d06915fa539	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_368	10	22	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:34:15.667983+00	2025-06-13 12:27:14.824158+00
627eeb4e-8235-4c19-b17d-aa7a038db3dc	2	\N	見習い狩人サラ_88	7	2	visiting	\N	2025-06-13 13:06:15.409136+00	2025-06-13 15:50:15.409136+00	f	\N	\N	2025-06-13 13:06:15.408403+00	2025-06-13 13:06:15.408403+00
11b42bf7-f06e-4c54-86b6-e5cc879c790e	1	\N	村の少年タム_805	7	46	visiting	\N	2025-06-13 13:06:55.383541+00	2025-06-13 15:52:55.383541+00	f	\N	\N	2025-06-13 13:06:55.382345+00	2025-06-13 13:06:55.382345+00
92bf9c98-e423-4c3e-878b-212da145f567	1	\N	村の少年タム_56	4	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:55:04.206173+00	2025-06-13 14:52:11.046295+00
1d9c3d68-c7e5-487d-ade6-31f8c61e2ba0	1	\N	村の少年タム_838	6	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:55:45.461435+00	2025-06-13 14:54:10.951855+00
6663c4a7-a7ee-485f-92f2-d0173c0a4cef	3	\N	魔法学校の生徒リオ_154	7	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:45.404495+00	2025-06-13 15:13:51.500622+00
a971ff36-8d0e-4797-b6d2-aeb8ee819db4	2	\N	見習い狩人サラ_857	10	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:45.404495+00	2025-06-13 15:24:03.903062+00
936024af-728a-4f8d-bbf8-d7a21e32cbb1	1	\N	村の少年タム_619	5	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:04:15.714434+00	2025-06-13 15:40:33.954142+00
5b45df2d-8851-4f87-ba13-0544cf299ec8	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_42	3	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:42:31.920716+00	2025-06-13 05:35:06.246555+00
efdfaaf1-cb69-443f-b3d2-60780aa400e9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_827	4	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:36.819306+00	2025-06-13 06:19:48.929154+00
103cdaf8-f63f-41c7-8b69-af3fc38d24c6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_418	4	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:36.819306+00	2025-06-13 06:42:46.82754+00
57b1f060-5686-4b79-a026-917515d9701a	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_799	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:42:31.920716+00	2025-06-13 07:13:13.236721+00
093baa69-64c3-41d2-8c05-7ee2570060ce	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_605	6	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:36.819306+00	2025-06-13 07:21:02.821192+00
e21bcebc-8ad8-4fff-8091-5638d0ced3eb	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_712	4	12	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:42:31.920716+00	2025-06-13 08:57:24.711588+00
b739efec-f0c4-4d66-a920-6c4362b94e40	3	\N	魔法学校の生徒リオ_324	7	22	visiting	\N	2025-06-13 13:40:27.503475+00	2025-06-13 15:49:27.503475+00	f	\N	\N	2025-06-13 13:40:27.502036+00	2025-06-13 13:40:27.502036+00
10e941a3-13b6-4abc-b265-d2fa00a9e7cd	2	\N	見習い狩人サラ_616	9	37	visiting	\N	2025-06-13 13:41:36.562233+00	2025-06-13 16:23:36.562233+00	f	\N	\N	2025-06-13 13:41:36.561295+00	2025-06-13 13:41:36.561295+00
7c2dd7f0-7e05-400f-8517-fa2912a4a751	3	\N	魔法学校の生徒リオ_156	8	9	visiting	\N	2025-06-13 13:44:06.623625+00	2025-06-13 16:22:06.623625+00	f	\N	\N	2025-06-13 13:44:06.621963+00	2025-06-13 13:44:06.621963+00
af81e77f-827d-4ab1-b1db-46d7aad27f25	2	\N	見習い狩人サラ_997	10	47	visiting	\N	2025-06-13 13:44:06.623625+00	2025-06-13 16:37:06.623625+00	f	\N	\N	2025-06-13 13:44:06.621963+00	2025-06-13 13:44:06.621963+00
53997c6f-8637-4a74-87f0-3087f2f24bb6	3	\N	魔法学校の生徒リオ_821	6	28	visiting	\N	2025-06-13 13:46:36.569328+00	2025-06-13 16:13:36.569328+00	f	\N	\N	2025-06-13 13:46:36.568034+00	2025-06-13 13:46:36.568034+00
6b803dfe-a930-45c8-8289-3a76acc94632	3	\N	魔法学校の生徒リオ_704	4	12	visiting	\N	2025-06-13 13:46:58.149965+00	2025-06-13 15:49:58.149965+00	f	\N	\N	2025-06-13 13:46:58.148535+00	2025-06-13 13:46:58.148535+00
b01c133e-1d4d-4a8b-b008-32b35c07c041	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_750	6	34	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:35:29.71657+00	2025-06-13 12:27:14.436454+00
bd6b5cb7-72b6-4a25-a2dd-395646a0eb9e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_137	8	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:35:29.71657+00	2025-06-13 12:27:14.436454+00
035a6fef-87ab-4e2c-aafb-dc1bbd079df6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_982	3	12	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:19:40.113094+00	2025-06-13 12:27:14.743793+00
cee2745a-25db-4eeb-8e78-5fd8371b421c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_135	10	48	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:19:40.113094+00	2025-06-13 12:27:14.891278+00
27957315-4650-4449-be63-012bd7575878	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_643	4	45	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:19:40.113094+00	2025-06-13 12:27:14.972797+00
e37d6870-9031-4c20-9e1d-7c3cb0efc6bf	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_323	10	53	returning	\N	\N	\N	f	\N	\N	2025-06-13 08:19:40.113094+00	2025-06-13 12:27:15.056475+00
6aefd13b-ade6-4478-8f0f-d56d3b5892a2	1	\N	村の少年タム_627	6	12	visiting	\N	2025-06-13 13:04:17.265832+00	2025-06-13 16:00:17.265832+00	f	\N	\N	2025-06-13 13:04:17.264805+00	2025-06-13 13:04:17.264805+00
200788ca-90a0-4441-a319-ab34827e679d	1	\N	村の少年タム_877	5	21	visiting	\N	2025-06-13 13:08:15.386018+00	2025-06-13 15:58:15.386018+00	f	\N	\N	2025-06-13 13:08:15.385175+00	2025-06-13 13:08:15.385175+00
9154b6e6-2f02-40c2-88d7-12602d5908f4	3	\N	魔法学校の生徒リオ_556	8	49	visiting	\N	2025-06-13 13:09:15.411031+00	2025-06-13 16:01:15.411031+00	f	\N	\N	2025-06-13 13:09:15.409633+00	2025-06-13 13:09:15.409633+00
92b6f090-8eee-4acc-bdd8-b910ebf51b84	2	\N	見習い狩人サラ_271	8	28	visiting	\N	2025-06-13 13:25:17.325764+00	2025-06-13 16:02:17.325764+00	f	\N	\N	2025-06-13 13:25:17.323931+00	2025-06-13 13:25:17.323931+00
02b64cf3-60bd-4838-9dd3-2f825b1ae359	3	\N	魔法学校の生徒リオ_535	6	49	visiting	\N	2025-06-13 13:25:55.919583+00	2025-06-13 15:49:55.919583+00	f	\N	\N	2025-06-13 13:25:55.918321+00	2025-06-13 13:25:55.918321+00
77184551-8dac-48fa-8f9e-d8f17388acb6	2	\N	見習い狩人サラ_986	7	30	visiting	\N	2025-06-13 13:37:27.741479+00	2025-06-13 16:37:27.741479+00	f	\N	\N	2025-06-13 13:37:27.740509+00	2025-06-13 13:37:27.740509+00
ba150299-fd31-46b2-91ac-fdc07e4ef65d	2	\N	見習い狩人サラ_537	10	16	visiting	\N	2025-06-13 13:47:07.24344+00	2025-06-13 16:09:07.24344+00	f	\N	\N	2025-06-13 13:47:07.242425+00	2025-06-13 13:47:07.242425+00
b900cf30-64ad-4949-a816-bc309d47cda4	3	\N	魔法学校の生徒リオ_46	8	35	visiting	\N	2025-06-13 13:47:14.56699+00	2025-06-13 15:52:14.56699+00	f	\N	\N	2025-06-13 13:47:14.565884+00	2025-06-13 13:47:14.565884+00
3e0b6297-2820-45d4-b97d-5128e8e4b6b0	2	\N	見習い狩人サラ_722	10	40	visiting	\N	2025-06-13 13:49:21.374936+00	2025-06-13 16:44:21.374936+00	f	\N	\N	2025-06-13 13:49:21.37397+00	2025-06-13 13:49:21.37397+00
89238c9b-c241-4c80-b1c0-416c1df5f06e	3	\N	魔法学校の生徒リオ_526	7	15	visiting	\N	2025-06-13 13:49:21.374936+00	2025-06-13 16:19:21.374936+00	f	\N	\N	2025-06-13 13:49:21.37397+00	2025-06-13 13:49:21.37397+00
4bada1a2-0e3a-4219-a090-60b6589240b1	3	\N	魔法学校の生徒リオ_677	4	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:49:21.37397+00	2025-06-13 14:52:11.046295+00
5ba2a130-f582-4213-a2db-22d681603c9d	1	\N	村の少年タム_204	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:04:45.424176+00	2025-06-13 14:52:11.046295+00
62382620-690d-4cb5-a34a-dcd534da383b	2	\N	見習い狩人サラ_204	6	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:45.420717+00	2025-06-13 14:52:11.046295+00
6b7e64f0-2e79-4077-af76-b28f00610bcd	3	\N	魔法学校の生徒リオ_717	8	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:05:45.408138+00	2025-06-13 14:52:11.046295+00
6e39f6ac-2d34-4348-9ecf-42104afc890c	2	\N	見習い狩人サラ_809	8	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:34:37.002358+00	2025-06-13 14:52:11.046295+00
84eb0718-9fc3-496e-9a19-c120c70633c3	1	\N	村の少年タム_583	5	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:04:17.264805+00	2025-06-13 14:52:11.046295+00
4700c907-5a56-4b4d-9756-d72a46def8e4	3	\N	魔法学校の生徒リオ_763	8	13	visiting	\N	2025-06-13 14:54:20.944994+00	2025-06-13 16:59:20.944994+00	f	\N	\N	2025-06-13 14:54:20.94282+00	2025-06-13 14:54:20.94282+00
c0e56d49-9085-4405-b8a8-090b83bbbebc	3	\N	魔法学校の生徒リオ_37	5	11	visiting	\N	2025-06-13 14:54:20.944994+00	2025-06-13 16:19:20.944994+00	f	\N	\N	2025-06-13 14:54:20.94282+00	2025-06-13 14:54:20.94282+00
ee631444-eec0-4f23-b4c1-2e027dba1e86	2	\N	見習い狩人サラ_823	8	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:15.483747+00	2025-06-13 14:54:41.399466+00
b14e4529-9888-4717-88a2-3671bd9a0c4d	2	\N	見習い狩人サラ_832	6	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:25:55.918321+00	2025-06-13 14:55:10.915971+00
148f348a-7fc7-4dba-b5a6-212494d9da82	3	\N	魔法学校の生徒リオ_859	6	47	visiting	\N	2025-06-13 14:55:11.035379+00	2025-06-13 17:04:11.035379+00	f	\N	\N	2025-06-13 14:55:11.034093+00	2025-06-13 14:55:11.034093+00
01e8492d-2b62-43f5-8632-c9ea97fd5496	2	\N	見習い狩人サラ_737	9	21	visiting	\N	2025-06-13 14:55:11.035379+00	2025-06-13 16:40:11.035379+00	f	\N	\N	2025-06-13 14:55:11.034093+00	2025-06-13 14:55:11.034093+00
20234835-bcb8-41ca-8b04-d04bc8c3f13e	2	\N	見習い狩人サラ_117	9	1	visiting	\N	2025-06-13 14:55:11.035379+00	2025-06-13 17:51:11.035379+00	f	\N	\N	2025-06-13 14:55:11.034093+00	2025-06-13 14:55:11.034093+00
20a6aa23-6c80-4c0e-ba18-2de6083f00dc	3	\N	魔法学校の生徒リオ_945	5	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:37:06.62982+00	2025-06-13 14:58:10.967394+00
cef0b1a6-42cd-4663-9abd-1a4824d70dbb	3	\N	魔法学校の生徒リオ_272	4	2	visiting	\N	2025-06-13 14:59:04.617715+00	2025-06-13 16:55:04.617715+00	f	\N	\N	2025-06-13 14:59:04.615797+00	2025-06-13 14:59:04.615797+00
abf3c73c-5b94-4961-bcd8-d2b09c14b174	2	\N	見習い狩人サラ_412	8	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:48.416019+00	2025-06-13 15:00:10.92974+00
35d02b8f-1dd8-4c53-a499-a32c84a7286e	2	\N	見習い狩人サラ_818	9	37	visiting	\N	2025-06-13 15:09:51.481783+00	2025-06-13 17:26:51.481783+00	f	\N	\N	2025-06-13 15:09:51.480115+00	2025-06-13 15:09:51.480115+00
3ab1e68c-a945-40e2-9d19-a26f42de9d1a	3	\N	魔法学校の生徒リオ_549	4	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:36:36.597777+00	2025-06-13 15:10:51.377575+00
7c52963a-8e5c-49ec-b379-4194b2ce29eb	2	\N	見習い狩人サラ_68	6	1	visiting	\N	2025-06-13 15:11:31.577432+00	2025-06-13 16:41:31.577432+00	f	\N	\N	2025-06-13 15:11:31.576026+00	2025-06-13 15:11:31.576026+00
a193e1ad-d137-45bb-a9be-873e15845a53	3	\N	魔法学校の生徒リオ_683	7	2	visiting	\N	2025-06-13 15:11:31.577432+00	2025-06-13 17:51:31.577432+00	f	\N	\N	2025-06-13 15:11:31.576026+00	2025-06-13 15:11:31.576026+00
d389b6ff-a37e-4de1-8d8d-b7a0f5ffbb88	3	\N	魔法学校の生徒リオ_197	6	37	visiting	\N	2025-06-13 15:11:31.577432+00	2025-06-13 17:39:31.577432+00	f	\N	\N	2025-06-13 15:11:31.576026+00	2025-06-13 15:11:31.576026+00
3eaefccc-f0fc-46a4-92fd-95d3e481d2e2	3	\N	魔法学校の生徒リオ_620	4	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:09:45.465851+00	2025-06-13 15:23:03.903585+00
cd119c51-920c-41a8-bd4a-c95c06d5990c	3	\N	魔法学校の生徒リオ_460	5	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:40:27.502036+00	2025-06-13 15:26:33.9524+00
fecfd674-43e6-4bb4-a05f-8be1a431cb8e	3	\N	魔法学校の生徒リオ_148	4	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:37:27.740509+00	2025-06-13 15:27:33.906449+00
b8912832-21eb-4115-8ec1-4109f8300c54	2	\N	見習い狩人サラ_738	8	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:47:07.242425+00	2025-06-13 15:30:33.917627+00
059fab66-d854-47c1-90c6-9a04c07ea280	1	\N	村の少年タム_723	6	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:45.420717+00	2025-06-13 15:34:03.893434+00
9c6bffd9-433e-49b0-a413-243e63611e50	3	\N	魔法学校の生徒リオ_346	4	34	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:47:14.565884+00	2025-06-13 15:35:34.131236+00
a8ba27fa-aab2-48c6-9339-ff102107adb4	2	\N	見習い狩人サラ_247	6	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:47:07.242425+00	2025-06-13 15:39:33.940158+00
7af10224-fb0c-4cd1-80a0-4bcfa5b5fe0a	2	\N	見習い狩人サラ_904	6	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:37:06.62982+00	2025-06-13 15:42:33.922994+00
39dced39-ca53-4574-b3c1-9ce517420246	2	\N	見習い狩人サラ_390	7	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:25:55.918321+00	2025-06-13 15:44:03.950411+00
298805be-d142-48a4-b10e-b08a2d13ff50	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_869	10	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:47.005002+00	2025-06-13 07:38:15.899084+00
bb732637-7d99-4886-acbf-d6c651aa36b2	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_923	3	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:46.661771+00	2025-06-13 07:40:15.94835+00
01843b9a-b868-4c72-8293-8d9f30a58e8c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_820	9	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:56:58.750388+00	2025-06-13 12:27:14.436454+00
0d3a2570-e60a-4d14-bf69-a94d14c8e39c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_151	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:56:58.750388+00	2025-06-13 12:27:14.436454+00
c2bbe5d3-e990-4fca-bb36-82be89f7fb51	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_503	5	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:56:58.750388+00	2025-06-13 12:27:14.436454+00
fd1df051-bcf8-446c-9cec-8282b8637f64	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_98	7	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:01.995312+00	2025-06-13 05:41:04.537096+00
8aa3d2d6-fa4a-44aa-8a6f-f374874a3c5f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_487	7	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:47.005002+00	2025-06-13 05:46:53.91743+00
ec31fb70-b2e1-4717-8dd6-4c498114fcf6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_265	4	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:01.995312+00	2025-06-13 05:50:23.937851+00
7b1981f5-ee13-403f-a3a1-d89fc09b12ab	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_422	6	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:26.803036+00	2025-06-13 05:54:54.645875+00
3a454f27-a33e-4a09-8f9b-9c1892ae66dd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_380	5	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:02.311751+00	2025-06-13 05:56:24.275187+00
2412718f-3b0c-420e-8bc5-cbd932b6cfde	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_485	7	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:56.846031+00	2025-06-13 06:04:43.120378+00
6551c57f-0d43-4197-816d-5eb13fa22ec0	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_287	6	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:26.803036+00	2025-06-13 06:04:43.120378+00
5c3dd98d-4a88-4ab0-ac2d-9801873a946a	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_795	7	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:44:32.151948+00	2025-06-13 06:09:38.772906+00
d5ff2293-86e7-4ecf-ada0-9a5baf850c01	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_14	6	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:42:04.069229+00	2025-06-13 06:10:08.772394+00
4d5dcb7e-1590-4f21-bc7c-b4d93278f1a1	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_383	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:56.78733+00	2025-06-13 06:12:08.749453+00
31a31bb0-3e62-449e-a7f3-301c6655039a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_795	8	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:44:01.852362+00	2025-06-13 06:16:03.68545+00
4d747867-3a39-45cd-803e-cdaa17d8e075	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_54	7	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:44:32.151948+00	2025-06-13 06:17:48.689612+00
a28a49b3-c4a4-4022-8ff8-46c05f3823ef	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_997	10	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:43.623318+00	2025-06-13 06:18:48.67164+00
0e5794cc-babb-458a-8d12-d459d6683643	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_396	6	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:26.803036+00	2025-06-13 06:20:48.680809+00
779610fa-ab55-49ed-bfbb-6bbf21b3427c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_807	7	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:02.311751+00	2025-06-13 06:24:18.665801+00
61b507ce-27c7-4c0c-b476-1bfadc59d5b7	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_421	6	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:43.623318+00	2025-06-13 06:25:48.953794+00
a6c2c913-bf0e-4358-b6a7-2f01656c65e7	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_168	7	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:01.842236+00	2025-06-13 06:28:24.792823+00
87141734-bed9-42a7-be29-f593acaf66ba	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_843	8	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:44:01.852362+00	2025-06-13 06:29:24.777832+00
22f8c5be-7aa4-4ea6-bb0a-5eb101ce65a8	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_251	10	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:01.842236+00	2025-06-13 06:31:24.738912+00
fe2b6409-3e2a-4f4f-817f-56ba71a2d916	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_931	9	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:46.661771+00	2025-06-13 06:32:54.779117+00
2f6eec57-9b80-48de-aab7-a1841e71fec6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_343	7	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:26.920958+00	2025-06-13 06:35:54.742557+00
05fb5f10-22a9-4159-a812-3a42edeed8fa	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_166	6	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:56.846031+00	2025-06-13 06:36:24.751982+00
fea88a57-9a09-4a06-9736-2251197f11f4	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_437	4	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:43.623318+00	2025-06-13 06:42:46.82754+00
1907ae80-45a6-4b2f-95dd-2b3e84c2b82c	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_707	4	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:01.842236+00	2025-06-13 07:13:13.236721+00
2f64ceb6-7bf2-43fe-9110-a9a5eec8d0ba	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_942	6	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:46.661771+00	2025-06-13 07:13:13.236721+00
433719e8-fe6e-4138-9a93-4a8ec3adeb7f	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_905	4	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:26.803036+00	2025-06-13 07:13:13.236721+00
4989ccb6-4992-42b8-a827-53d20aa681f8	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_796	7	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:56.846031+00	2025-06-13 07:13:13.236721+00
5253c2dd-57da-4c97-a061-4d84a710ca50	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_910	8	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:46.661771+00	2025-06-13 07:13:13.236721+00
54e5a98d-d5f9-47b7-ab7b-d949474c2c1a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_855	6	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:56.92433+00	2025-06-13 07:13:13.236721+00
887eab59-c6c5-4e91-a4e4-2ccc7433f0bb	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_689	5	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:02.311751+00	2025-06-13 07:13:13.236721+00
d960828e-420f-4d13-9028-927293a37e28	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_582	6	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:56.846031+00	2025-06-13 07:17:42.133454+00
f80115b8-f0f6-46a8-a078-ac1e866eb0bb	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_134	6	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:01.995312+00	2025-06-13 07:17:42.133454+00
deef7eaa-80e0-4b3e-b940-4dd3179e2711	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_723	5	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:56.846031+00	2025-06-13 07:22:13.821781+00
84cfcd5f-e6b4-4a05-bb0f-0fec7c09cb3a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_852	8	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:32.164421+00	2025-06-13 07:23:51.965244+00
d56b379b-617b-40f2-b1a8-c33cca540aa5	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_82	5	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:01.995312+00	2025-06-13 07:25:03.702286+00
2c33e8f5-306f-4563-a1b4-7d226d6b205c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_926	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:46:43.623318+00	2025-06-13 07:26:03.655881+00
9ad94b34-9b05-4398-abf7-a8666af8e94c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_70	10	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:56.78733+00	2025-06-13 07:26:03.655881+00
3d9a9476-6d96-4f10-a4d6-42d0adaa51fd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_268	5	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:01.995312+00	2025-06-13 07:29:03.646949+00
632153bf-cb66-47bb-92d2-328dfa22eb8b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_287	4	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:02.311751+00	2025-06-13 07:34:45.995119+00
b3039566-2f01-4650-ae7e-a15ad3d2c28c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_594	6	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:42:04.069229+00	2025-06-13 07:34:45.995119+00
97dacd96-aedb-4a90-9f38-4c725f65fd49	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_579	10	24	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:45:47.005002+00	2025-06-13 08:57:24.767652+00
15f48f82-4f6c-4d82-8767-7d4efb2d42c9	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_378	7	13	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:46:26.803036+00	2025-06-13 08:57:24.792182+00
35da8604-6a61-4164-9408-4a2868cdb0a4	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_317	8	34	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:47:46.661771+00	2025-06-13 08:58:17.244505+00
d7bd5cb0-30dc-4277-9609-f35423f30895	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_720	4	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:56:58.750388+00	2025-06-13 12:27:14.436454+00
ea1eb86c-d2af-47af-9157-6d6bea988242	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_522	7	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 08:56:58.750388+00	2025-06-13 12:27:14.436454+00
18800a2f-3a2f-4fb7-8a12-bc3c7ccd473d	2	\N	見習い狩人サラ_919	7	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:02.467022+00	2025-06-13 14:52:11.046295+00
22500371-d0e6-4451-a515-2183836815f7	2	\N	見習い狩人サラ_653	8	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:02.467022+00	2025-06-13 15:04:31.785898+00
669b4c56-7ca0-46d0-846e-7977093c1caa	3	\N	魔法学校の生徒リオ_508	4	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:04.330882+00	2025-06-13 15:19:33.904856+00
c19f05ac-325c-4a16-817f-f5bf77b59c09	3	\N	魔法学校の生徒リオ_755	7	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:46:47.668924+00	2025-06-13 15:28:03.905999+00
7e376b72-4a8e-4ac5-8881-01c00401068a	2	\N	見習い狩人サラ_444	10	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:30:16.00358+00	2025-06-13 15:28:33.886859+00
2830d7fd-9ace-4836-b8b0-780b3d54c894	1	\N	村の少年タム_678	5	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:01:45.477209+00	2025-06-13 15:38:06.660165+00
e6900be4-e22f-4440-8c79-fbcec8886b90	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_624	6	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:31.736429+00	2025-06-13 05:36:58.422818+00
cdcb9e6f-66e9-4638-ae0e-193af2caf9b7	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_791	5	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:26.994344+00	2025-06-13 05:39:34.518536+00
422e1ee4-e007-4694-848a-39d52fca8654	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_381	4	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:31.736429+00	2025-06-13 06:11:38.724075+00
6eae64ab-73f0-4523-a6bb-ddb38ff20b1e	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_68	8	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:31.736429+00	2025-06-13 07:13:13.236721+00
f9592cdd-8f9d-4b6c-b544-1db258269cdd	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_441	4	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:31.736429+00	2025-06-13 07:28:33.633003+00
140cb959-2a8f-42a3-aa48-3b20ce7a0718	3	\N	魔法学校の生徒リオ_64	6	8	visiting	\N	2025-06-13 13:50:21.354072+00	2025-06-13 15:51:21.354072+00	f	\N	\N	2025-06-13 13:50:21.352779+00	2025-06-13 13:50:21.352779+00
1be27b7e-397d-4e44-9910-87314b5985be	3	\N	魔法学校の生徒リオ_770	5	30	visiting	\N	2025-06-13 13:50:33.287926+00	2025-06-13 16:02:33.287926+00	f	\N	\N	2025-06-13 13:50:33.287071+00	2025-06-13 13:50:33.287071+00
c4fb8966-cb4f-49c8-9eb7-80e03c6ec3ad	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_851	8	14	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:47:56.78733+00	2025-06-13 08:58:17.36292+00
f728110b-7d25-4d7f-9cc7-c59f122edf45	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_30	9	54	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:49:26.994344+00	2025-06-13 09:01:41.124492+00
20335aa0-89fd-4a6b-967c-77d75257a1bc	\N	119e86b2-8d18-467c-a6da-09df465a01de	見習い冒険者 アリス	1	50	idle	\N	\N	\N	t	6	\N	2025-06-13 09:20:50.327132+00	2025-06-13 12:27:14.436454+00
64891789-1c95-41d9-bbf6-7ee104eb5b1d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_278	6	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 09:20:50.327132+00	2025-06-13 12:27:14.436454+00
f078e42d-cf14-43d7-96eb-4b7a7493e39e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_301	8	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 09:20:50.327132+00	2025-06-13 12:27:14.436454+00
aff8512d-b606-4f6c-82c0-d3d58f81427a	2	\N	見習い狩人サラ_734	8	46	visiting	\N	2025-06-13 13:35:38.383556+00	2025-06-13 16:20:38.383556+00	f	\N	\N	2025-06-13 13:35:38.382688+00	2025-06-13 13:35:38.382688+00
9d47dd54-de87-436c-a65f-5e4e1ab5174e	3	\N	魔法学校の生徒リオ_133	6	35	visiting	\N	2025-06-13 13:36:06.666429+00	2025-06-13 16:19:06.666429+00	f	\N	\N	2025-06-13 13:36:06.665486+00	2025-06-13 13:36:06.665486+00
b7152b70-dc8f-4105-8f16-a3a88f41dd87	2	\N	見習い狩人サラ_609	9	33	visiting	\N	2025-06-13 13:40:36.53822+00	2025-06-13 15:53:36.53822+00	f	\N	\N	2025-06-13 13:40:36.537322+00	2025-06-13 13:40:36.537322+00
7c5f88e6-f93e-4e38-80e9-deb7c7a94e4b	2	\N	見習い狩人サラ_274	9	17	visiting	\N	2025-06-13 13:41:06.507668+00	2025-06-13 15:59:06.507668+00	f	\N	\N	2025-06-13 13:41:06.506637+00	2025-06-13 13:41:06.506637+00
668c1ae7-7e17-42c5-901e-498a54911358	2	\N	見習い狩人サラ_970	6	30	visiting	\N	2025-06-13 13:43:06.667604+00	2025-06-13 15:52:06.667604+00	f	\N	\N	2025-06-13 13:43:06.66654+00	2025-06-13 13:43:06.66654+00
0bd7a8e1-8beb-4e3a-9625-9e209a3dc1df	3	\N	魔法学校の生徒リオ_931	4	45	visiting	\N	2025-06-13 13:45:06.580487+00	2025-06-13 15:56:06.580487+00	f	\N	\N	2025-06-13 13:45:06.578828+00	2025-06-13 13:45:06.578828+00
b5f68624-8364-4265-a4a9-e9cfae932dce	2	\N	見習い狩人サラ_431	7	50	visiting	\N	2025-06-13 13:49:51.365196+00	2025-06-13 16:19:51.365196+00	f	\N	\N	2025-06-13 13:49:51.364196+00	2025-06-13 13:49:51.364196+00
1af04060-bd0b-4d6c-9f3a-3d77cbc26c47	3	\N	魔法学校の生徒リオ_179	4	18	visiting	\N	2025-06-13 13:49:51.365196+00	2025-06-13 16:05:51.365196+00	f	\N	\N	2025-06-13 13:49:51.364196+00	2025-06-13 13:49:51.364196+00
a78b0549-a730-45fb-853a-e44d4d3d637c	2	\N	見習い狩人サラ_678	9	39	visiting	\N	2025-06-13 13:50:33.287926+00	2025-06-13 16:27:33.287926+00	f	\N	\N	2025-06-13 13:50:33.287071+00	2025-06-13 13:50:33.287071+00
0d05e00f-6dbf-4e27-b748-4fdbea5a2ed9	3	\N	魔法学校の生徒リオ_640	8	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:25:47.153519+00	2025-06-13 14:52:11.046295+00
8735383b-96af-4d15-8d87-8debf217d559	2	\N	見習い狩人サラ_495	10	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:35:38.382688+00	2025-06-13 14:52:11.046295+00
9ca70ead-e63d-4cfb-a920-5a6ea7390232	3	\N	魔法学校の生徒リオ_601	6	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:55.382345+00	2025-06-13 14:52:11.046295+00
a22f1690-1463-41cb-a668-1ba13bbdcd57	2	\N	見習い狩人サラ_120	10	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:36.902393+00	2025-06-13 14:52:11.046295+00
ccc81575-0803-4f76-92c6-787541d48c2e	1	\N	村の少年タム_413	4	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:07:45.43785+00	2025-06-13 14:52:11.046295+00
d8502c25-ba27-427f-875d-899eeb2d05cf	3	\N	魔法学校の生徒リオ_620	8	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:07:45.43785+00	2025-06-13 14:52:11.046295+00
e35a4023-41ab-4276-84c4-411e0f71f6e8	2	\N	見習い狩人サラ_265	10	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:34:37.93396+00	2025-06-13 14:52:11.046295+00
e772d699-1502-4ab2-a429-93e8b16dedef	2	\N	見習い狩人サラ_386	10	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:43:06.66654+00	2025-06-13 14:52:11.046295+00
ed64454e-8515-4642-801e-51903fd0a5ed	3	\N	魔法学校の生徒リオ_718	6	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:36:06.665486+00	2025-06-13 14:52:11.046295+00
f6621cf7-fd0a-42ca-bee1-5afc33f7a884	2	\N	見習い狩人サラ_834	7	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:15.782307+00	2025-06-13 14:52:11.046295+00
fa939190-b9d8-44d0-8247-6522c7f7b25c	2	\N	見習い狩人サラ_421	9	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:42:06.566782+00	2025-06-13 14:52:11.046295+00
6b80ae3c-a475-47c1-950d-9f123a0d333e	1	\N	村の少年タム_634	7	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:08:45.42208+00	2025-06-13 14:54:10.951855+00
00d6cbc3-4780-4426-9cd3-e7092f3ce743	2	\N	見習い狩人サラ_666	7	39	visiting	\N	2025-06-13 14:55:43.447742+00	2025-06-13 17:05:43.447742+00	f	\N	\N	2025-06-13 14:55:43.446091+00	2025-06-13 14:55:43.446091+00
3cac6b84-b5f9-40c7-94fd-64f25f8e3cb5	3	\N	魔法学校の生徒リオ_332	4	17	visiting	\N	2025-06-13 14:55:43.447742+00	2025-06-13 17:08:43.447742+00	f	\N	\N	2025-06-13 14:55:43.446091+00	2025-06-13 14:55:43.446091+00
8d7ec874-6f8f-4d14-abf3-4286be556d9a	3	\N	魔法学校の生徒リオ_454	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:50:21.352779+00	2025-06-13 14:56:40.96128+00
3edfb7d4-9502-4c24-9361-3ba9f8ef5c41	1	\N	村の少年タム_65	3	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:08:45.42208+00	2025-06-13 14:59:41.243992+00
a6796745-d780-463b-a65e-086be1d37dce	2	\N	見習い狩人サラ_571	9	39	visiting	\N	2025-06-13 14:59:41.34485+00	2025-06-13 16:11:41.34485+00	f	\N	\N	2025-06-13 14:59:41.34368+00	2025-06-13 14:59:41.34368+00
74f8d5df-d6b3-4c2d-9cd7-83f46af7c01e	2	\N	見習い狩人サラ_99	10	46	visiting	\N	2025-06-13 14:59:41.34485+00	2025-06-13 15:54:41.34485+00	f	\N	\N	2025-06-13 14:59:41.34368+00	2025-06-13 14:59:41.34368+00
36898a9a-7de4-49d9-b679-f957fb97dcc6	2	\N	見習い狩人サラ_483	7	4	visiting	\N	2025-06-13 15:01:41.020051+00	2025-06-13 16:20:41.020051+00	f	\N	\N	2025-06-13 15:01:41.019052+00	2025-06-13 15:01:41.019052+00
3605d873-e3c0-4ca2-9dcb-721d56fa5c16	2	\N	見習い狩人サラ_655	6	39	visiting	\N	2025-06-13 15:01:41.020051+00	2025-06-13 17:27:41.020051+00	f	\N	\N	2025-06-13 15:01:41.019052+00	2025-06-13 15:01:41.019052+00
e8d71621-4795-4c5f-ab2f-9d2a2eb3234b	3	\N	魔法学校の生徒リオ_849	6	18	visiting	\N	2025-06-13 15:02:11.018758+00	2025-06-13 16:12:11.018758+00	f	\N	\N	2025-06-13 15:02:11.017665+00	2025-06-13 15:02:11.017665+00
8f4cfc1d-1b90-4f4b-930a-16be4dd9dc57	2	\N	見習い狩人サラ_238	7	8	visiting	\N	2025-06-13 15:02:11.018758+00	2025-06-13 17:14:11.018758+00	f	\N	\N	2025-06-13 15:02:11.017665+00	2025-06-13 15:02:11.017665+00
8fdf6bf3-573b-4a1e-9b26-fd42e9422c9f	2	\N	見習い狩人サラ_887	10	6	visiting	\N	2025-06-13 15:02:11.018758+00	2025-06-13 16:39:11.018758+00	f	\N	\N	2025-06-13 15:02:11.017665+00	2025-06-13 15:02:11.017665+00
033c9001-eae2-4aa1-991c-9b4d7055f297	3	\N	魔法学校の生徒リオ_266	8	31	visiting	\N	2025-06-13 15:02:41.048024+00	2025-06-13 16:19:41.048024+00	f	\N	\N	2025-06-13 15:02:41.047184+00	2025-06-13 15:02:41.047184+00
8f16acd0-7514-4986-aa14-a296781b9818	3	\N	魔法学校の生徒リオ_924	7	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:35:38.382688+00	2025-06-13 15:09:51.343364+00
a55028d5-6d13-4114-a618-161f6103d119	2	\N	見習い狩人サラ_141	6	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:40:36.537322+00	2025-06-13 15:10:51.377575+00
f53a0731-ad96-470c-abe0-0b0afa70f571	2	\N	見習い狩人サラ_378	6	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:36.902393+00	2025-06-13 15:10:51.377575+00
902229c9-dfa4-4951-ae54-90af16192372	1	\N	村の少年タム_316	4	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:07:45.43785+00	2025-06-13 15:13:51.500622+00
678ac050-fa95-493f-a5c5-51e02bd5b430	2	\N	見習い狩人サラ_296	10	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:45:06.578828+00	2025-06-13 15:19:33.904856+00
03a66652-7d50-4570-b7c7-9f7695233747	2	\N	見習い狩人サラ_556	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:36.902393+00	2025-06-13 15:22:03.907505+00
bbe65a08-5167-44fb-8bb0-426dca0d8200	2	\N	見習い狩人サラ_946	10	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:41:06.506637+00	2025-06-13 15:25:33.865435+00
528e4360-a3f5-4057-8d2b-d92f0056502f	1	\N	村の少年タム_828	7	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:55.382345+00	2025-06-13 15:32:06.199771+00
f6261809-e04e-4d7e-8097-3d2bd2d05181	3	\N	魔法学校の生徒リオ_255	6	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:49:51.364196+00	2025-06-13 15:34:03.893434+00
9e18cb9f-400a-47e3-8983-afb7198d1f71	3	\N	魔法学校の生徒リオ_612	8	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:50:21.352779+00	2025-06-13 15:35:34.131236+00
5b0b3f75-a565-4a54-a0cc-090a76c349a4	2	\N	見習い狩人サラ_82	8	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:40:36.537322+00	2025-06-13 15:37:03.919623+00
1c0e5617-862d-4476-b93e-dff458f4eb9d	2	\N	見習い狩人サラ_782	8	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:36:06.665486+00	2025-06-13 15:39:33.940158+00
b37d95ce-4e8f-4574-a6da-f79c97034018	2	\N	見習い狩人サラ_918	10	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:59:41.34368+00	2025-06-13 15:45:04.031926+00
7b22c169-b0eb-4c8b-a3f7-ed5915698110	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_559	5	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:50:26.891965+00	2025-06-13 06:10:38.764948+00
bb9d87e3-73fa-42ee-a28e-b33d87ae758b	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_491	7	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:48:26.805734+00	2025-06-13 06:30:54.754816+00
86d0474d-ee20-43eb-83a7-f035aaac83b6	\N	119e86b2-8d18-467c-a6da-09df465a01de	見習い冒険者 アリス	1	50	idle	\N	\N	\N	t	6	\N	2025-06-13 04:48:26.805734+00	2025-06-13 06:31:54.723361+00
3bb72e3d-4093-4e14-b911-c8a70d5f1394	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_167	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:50:26.891965+00	2025-06-13 06:36:54.768439+00
dd8c8835-caf4-4b6b-a43a-ce9ee285cabd	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_791	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:50:26.891965+00	2025-06-13 07:13:13.236721+00
3924e217-b079-4dfb-9bda-070bbf392626	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_73	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:48:26.805734+00	2025-06-13 07:24:51.993455+00
2f3e7d79-09cb-4a09-8808-26d059aeb6bf	2	\N	見習い狩人サラ_685	10	35	visiting	\N	2025-06-13 13:46:06.624881+00	2025-06-13 16:37:06.624881+00	f	\N	\N	2025-06-13 13:46:06.623819+00	2025-06-13 13:46:06.623819+00
2bd33839-9d42-48e7-9289-84a76f505c34	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_756	8	22	returning	\N	\N	\N	f	\N	\N	2025-06-13 12:27:15.255418+00	2025-06-13 13:48:26.337039+00
329179c5-8ec7-4aa4-b3af-db6ff973dc94	3	\N	魔法学校の生徒リオ_183	6	6	visiting	\N	2025-06-13 13:50:51.446443+00	2025-06-13 16:26:51.446443+00	f	\N	\N	2025-06-13 13:50:51.445576+00	2025-06-13 13:50:51.445576+00
16dfa871-4020-4a3f-a9dd-345a78da5a39	2	\N	見習い狩人サラ_280	9	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:43:34.59385+00	2025-06-13 14:52:11.046295+00
1a27a0bb-fcc5-4f88-a2bb-7bf3e889fd9b	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_207	7	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:29:55.031613+00	2025-06-13 14:52:11.046295+00
ef4e2721-37a0-4102-9bfe-322a845babe8	\N	119e86b2-8d18-467c-a6da-09df465a01de	見習い冒険者 アリス	1	55	returning	\N	\N	\N	t	6	\N	2025-06-13 12:27:15.255418+00	2025-06-13 12:57:45.304703+00
47abc637-60bd-4507-a43e-2019980ea983	\N	\N	見習い冒険者 アリス	1	50	visiting	\N	2025-06-13 12:57:45.469854+00	2025-06-13 16:55:45.469854+00	t	6	\N	2025-06-13 12:57:45.468351+00	2025-06-13 12:57:45.468351+00
61935c32-0782-47a8-a0be-fd5330032703	2	\N	見習い狩人サラ_331	7	3	visiting	\N	2025-06-13 13:08:15.42406+00	2025-06-13 15:56:15.42406+00	f	\N	\N	2025-06-13 13:08:15.423048+00	2025-06-13 13:08:15.423048+00
dd3a914b-2f2e-4817-820a-a2f7511f6f94	2	\N	見習い狩人サラ_200	6	16	visiting	\N	2025-06-13 13:09:06.468147+00	2025-06-13 15:48:06.468147+00	f	\N	\N	2025-06-13 13:09:06.467288+00	2025-06-13 13:09:06.467288+00
1fd172c5-68f1-4b7d-9bb1-19f25c4e33c4	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_621	4	51	returning	\N	\N	\N	f	\N	\N	2025-06-13 12:27:15.255418+00	2025-06-13 13:09:45.304807+00
408324c3-3986-4a1e-a243-1fa68894c5bb	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_544	7	53	returning	\N	\N	\N	f	\N	\N	2025-06-13 12:27:15.255418+00	2025-06-13 13:24:47.353588+00
e29ea075-3a55-466e-91e5-e97c4b76b9dd	2	\N	見習い狩人サラ_873	9	45	visiting	\N	2025-06-13 13:36:36.598922+00	2025-06-13 16:29:36.598922+00	f	\N	\N	2025-06-13 13:36:36.597777+00	2025-06-13 13:36:36.597777+00
e86cb420-73ab-427d-9354-1f5c4f2bf5bf	3	\N	魔法学校の生徒リオ_251	6	5	visiting	\N	2025-06-13 13:38:06.545467+00	2025-06-13 16:17:06.545467+00	f	\N	\N	2025-06-13 13:38:06.544533+00	2025-06-13 13:38:06.544533+00
4230949e-918d-4290-a49e-62d407587b12	2	\N	見習い狩人サラ_911	8	22	visiting	\N	2025-06-13 13:39:36.614295+00	2025-06-13 15:54:36.614295+00	f	\N	\N	2025-06-13 13:39:36.613057+00	2025-06-13 13:39:36.613057+00
08f11f1b-2fff-4073-9452-f27154dfe7a3	3	\N	魔法学校の生徒リオ_35	8	24	visiting	\N	2025-06-13 13:42:36.536302+00	2025-06-13 16:42:36.536302+00	f	\N	\N	2025-06-13 13:42:36.53506+00	2025-06-13 13:42:36.53506+00
49bfadef-0bba-4330-b949-a6cee325540d	2	\N	見習い狩人サラ_222	10	28	visiting	\N	2025-06-13 13:43:34.595186+00	2025-06-13 16:31:34.595186+00	f	\N	\N	2025-06-13 13:43:34.59385+00	2025-06-13 13:43:34.59385+00
52dff9a1-234f-422e-8dcc-6fd618260976	3	\N	魔法学校の生徒リオ_623	5	39	visiting	\N	2025-06-13 13:43:34.595186+00	2025-06-13 16:25:34.595186+00	f	\N	\N	2025-06-13 13:43:34.59385+00	2025-06-13 13:43:34.59385+00
00168550-5fb6-4e70-84ee-9330970d737d	2	\N	見習い狩人サラ_547	7	23	visiting	\N	2025-06-13 13:43:36.567068+00	2025-06-13 16:20:36.567068+00	f	\N	\N	2025-06-13 13:43:36.566204+00	2025-06-13 13:43:36.566204+00
5c848661-7500-4655-a719-cbe72350106e	3	\N	魔法学校の生徒リオ_489	7	24	visiting	\N	2025-06-13 13:44:36.559033+00	2025-06-13 16:01:36.559033+00	f	\N	\N	2025-06-13 13:44:36.5578+00	2025-06-13 13:44:36.5578+00
1e3ba41d-a31f-4e52-bff0-992e3f39da44	2	\N	見習い狩人サラ_641	9	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:15.43042+00	2025-06-13 14:52:11.046295+00
893281e4-29ab-4530-9443-51d14cd65469	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_767	7	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:29:55.031613+00	2025-06-13 14:52:11.046295+00
a28087d3-875b-4cc9-b992-cf486759f6c2	2	\N	見習い狩人サラ_555	7	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:42:36.53506+00	2025-06-13 14:52:11.046295+00
f9d3d4b2-e599-4f86-8a47-0f9ac919c8a4	1	\N	村の少年タム_513	3	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:45.468351+00	2025-06-13 14:52:11.046295+00
6d95a44d-0a20-43b3-b165-9e8b1674afb3	3	\N	魔法学校の生徒リオ_821	5	10	visiting	\N	2025-06-13 14:55:53.943896+00	2025-06-13 15:56:53.943896+00	f	\N	\N	2025-06-13 14:55:53.941771+00	2025-06-13 14:55:53.941771+00
39005e4b-ac3a-4aea-96de-551f075ddaf5	3	\N	魔法学校の生徒リオ_115	8	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:26:17.267997+00	2025-06-13 14:56:40.96128+00
27496489-4a5c-4010-b13c-fd20b0da3745	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_321	4	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:29:55.031613+00	2025-06-13 15:00:10.92974+00
4ea339ec-c485-4cd7-abda-2cd0a2fbf96a	2	\N	見習い狩人サラ_256	7	36	visiting	\N	2025-06-13 15:00:11.042166+00	2025-06-13 17:51:11.042166+00	f	\N	\N	2025-06-13 15:00:11.040766+00	2025-06-13 15:00:11.040766+00
276d1ab1-2255-4c4f-add3-460dab4f5550	3	\N	魔法学校の生徒リオ_638	4	39	visiting	\N	2025-06-13 15:00:11.042166+00	2025-06-13 16:42:11.042166+00	f	\N	\N	2025-06-13 15:00:11.040766+00	2025-06-13 15:00:11.040766+00
59024cdd-6b3a-4deb-93bd-bbf0e95f052c	3	\N	魔法学校の生徒リオ_203	4	49	visiting	\N	2025-06-13 15:00:11.042166+00	2025-06-13 17:38:11.042166+00	f	\N	\N	2025-06-13 15:00:11.040766+00	2025-06-13 15:00:11.040766+00
4cfb14ee-53dc-442a-9cbd-fd887f0a12a5	3	\N	魔法学校の生徒リオ_118	7	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:42:36.53506+00	2025-06-13 15:00:40.948629+00
f4ca7cc4-8726-4914-a07b-d3af5c4a5f2e	2	\N	見習い狩人サラ_730	9	5	visiting	\N	2025-06-13 15:00:51.655359+00	2025-06-13 16:44:51.655359+00	f	\N	\N	2025-06-13 15:00:51.654212+00	2025-06-13 15:00:51.654212+00
d7a2b71e-5e2a-4faa-832e-6921ddd18cc3	2	\N	見習い狩人サラ_904	6	26	visiting	\N	2025-06-13 15:00:51.655359+00	2025-06-13 17:04:51.655359+00	f	\N	\N	2025-06-13 15:00:51.654212+00	2025-06-13 15:00:51.654212+00
0cd6c2bb-20f3-44bd-b05f-164da352a05f	2	\N	見習い狩人サラ_100	7	32	visiting	\N	2025-06-13 15:00:51.655359+00	2025-06-13 17:50:51.655359+00	f	\N	\N	2025-06-13 15:00:51.654212+00	2025-06-13 15:00:51.654212+00
16ac560c-9d61-4f02-97c4-b34b6d5a7e3a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_911	5	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:29:55.031613+00	2025-06-13 15:01:10.945311+00
b18edf47-4bfb-4f2a-9ad6-74bcd8603166	2	\N	見習い狩人サラ_562	10	22	visiting	\N	2025-06-13 15:01:11.057025+00	2025-06-13 17:56:11.057025+00	f	\N	\N	2025-06-13 15:01:11.056125+00	2025-06-13 15:01:11.056125+00
aa9bd696-7d86-4585-8ee9-ff5493ba74a2	2	\N	見習い狩人サラ_692	10	31	visiting	\N	2025-06-13 15:01:11.057025+00	2025-06-13 16:54:11.057025+00	f	\N	\N	2025-06-13 15:01:11.056125+00	2025-06-13 15:01:11.056125+00
8fb5bbb3-cc59-4082-9b76-27b55b811a3f	2	\N	見習い狩人サラ_776	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:39:32.463893+00	2025-06-13 15:02:40.932663+00
0b45ceea-d5b2-4927-81c4-bbfb4b7aefe0	2	\N	見習い狩人サラ_665	7	35	visiting	\N	2025-06-13 15:03:11.036538+00	2025-06-13 16:06:11.036538+00	f	\N	\N	2025-06-13 15:03:11.03542+00	2025-06-13 15:03:11.03542+00
7b5c71c8-9fc1-4aa6-8f95-4bd64b0e4971	2	\N	見習い狩人サラ_992	8	16	visiting	\N	2025-06-13 15:06:08.801863+00	2025-06-13 16:18:08.801863+00	f	\N	\N	2025-06-13 15:06:08.801061+00	2025-06-13 15:06:08.801061+00
ac768838-0d1a-49f2-a337-d1dbe8a1f2ec	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_812	6	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:29:55.031613+00	2025-06-13 15:15:21.477778+00
4e9df8d7-a1f7-4be0-be3a-0c63d24aba9a	2	\N	見習い狩人サラ_158	6	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:45:10.644127+00	2025-06-13 15:19:33.904856+00
9d3ffc05-5298-4f52-b2f1-0af17a76d9e6	2	\N	見習い狩人サラ_949	8	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:06.544533+00	2025-06-13 15:20:33.942497+00
a5e505c4-4132-43e0-8756-37a7d5de1073	2	\N	見習い狩人サラ_22	6	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:44:36.5578+00	2025-06-13 15:21:03.915716+00
a25fa313-685f-4f58-a62e-2dba00264d54	1	\N	村の少年タム_245	3	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:45.468351+00	2025-06-13 15:27:03.894926+00
af05dc7d-f50f-4c63-972d-8fcdd0b675be	3	\N	魔法学校の生徒リオ_88	5	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:43:36.566204+00	2025-06-13 15:34:03.893434+00
608c14d2-ad22-4969-a43d-fe9850a9d3d3	2	\N	見習い狩人サラ_268	9	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:44:36.5578+00	2025-06-13 15:38:06.660165+00
876488bb-b4f8-4374-9638-071ae399ee1a	1	\N	村の少年タム_135	5	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:09:06.467288+00	2025-06-13 15:41:33.931033+00
86835666-fa3e-4d7e-a93a-7b39fba6791f	3	\N	魔法学校の生徒リオ_154	6	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:55:53.941771+00	2025-06-13 15:45:04.031926+00
abf9a19a-bab2-4b60-a9af-126426daca1d	2	\N	見習い狩人サラ_60	8	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:08:15.423048+00	2025-06-13 15:45:33.947588+00
c2975fc4-18ae-441b-b9b8-a3be7e597e02	2	\N	見習い狩人サラ_240	6	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:38:06.544533+00	2025-06-13 15:45:33.947588+00
266a77a6-599e-49f4-96b6-3848d8e294c4	3	\N	魔法学校の生徒リオ_2	6	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:55:53.941771+00	2025-06-13 15:46:03.929878+00
547b6719-2795-4424-afa7-9743b6450b51	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_156	10	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:48:56.80669+00	2025-06-13 07:23:13.773318+00
e49ef9ac-c3f3-4656-ac5e-9f0ccb457f02	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_826	3	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:48:56.80669+00	2025-06-13 07:24:21.980618+00
3721e938-79f9-404f-9b70-95bdc299181c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_85	9	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:48:56.80669+00	2025-06-13 07:38:15.899084+00
de2fde5b-e34d-4aed-8b92-5cc826a1878c	3	\N	魔法学校の生徒リオ_283	7	38	visiting	\N	2025-06-13 13:37:34.385845+00	2025-06-13 16:16:34.385845+00	f	\N	\N	2025-06-13 13:37:34.384454+00	2025-06-13 13:37:34.384454+00
9fe5599b-e30e-48d2-86fb-3c62198bacf0	3	\N	魔法学校の生徒リオ_521	6	9	visiting	\N	2025-06-13 13:37:34.385845+00	2025-06-13 16:06:34.385845+00	f	\N	\N	2025-06-13 13:37:34.384454+00	2025-06-13 13:37:34.384454+00
35774f59-8f33-48e8-96e2-5b9e15a5641d	2	\N	見習い狩人サラ_919	7	36	visiting	\N	2025-06-13 13:37:34.385845+00	2025-06-13 16:15:34.385845+00	f	\N	\N	2025-06-13 13:37:34.384454+00	2025-06-13 13:37:34.384454+00
514571d9-c491-425b-91ea-26ca71b97ab8	3	\N	魔法学校の生徒リオ_570	5	28	visiting	\N	2025-06-13 13:37:36.6292+00	2025-06-13 16:02:36.6292+00	f	\N	\N	2025-06-13 13:37:36.627991+00	2025-06-13 13:37:36.627991+00
d04e45db-8023-48ac-84b0-b10438f81154	3	\N	魔法学校の生徒リオ_890	4	47	visiting	\N	2025-06-13 13:37:36.6292+00	2025-06-13 16:32:36.6292+00	f	\N	\N	2025-06-13 13:37:36.627991+00	2025-06-13 13:37:36.627991+00
4e710d27-99e8-4128-bd01-db90f9ee54ed	3	\N	魔法学校の生徒リオ_765	4	43	visiting	\N	2025-06-13 13:42:18.531996+00	2025-06-13 16:27:18.531996+00	f	\N	\N	2025-06-13 13:42:18.531172+00	2025-06-13 13:42:18.531172+00
8a0fbed9-d9a2-4957-b3ce-68e82431d87e	3	\N	魔法学校の生徒リオ_339	8	25	visiting	\N	2025-06-13 13:45:36.578258+00	2025-06-13 15:54:36.578258+00	f	\N	\N	2025-06-13 13:45:36.576548+00	2025-06-13 13:45:36.576548+00
36810ec7-afe0-47bc-a241-4107ec59a5a3	2	\N	見習い狩人サラ_410	7	5	visiting	\N	2025-06-13 13:45:36.578258+00	2025-06-13 16:19:36.578258+00	f	\N	\N	2025-06-13 13:45:36.576548+00	2025-06-13 13:45:36.576548+00
151ce65b-052c-4e05-953f-4dd2de5adb85	2	\N	見習い狩人サラ_910	8	6	visiting	\N	2025-06-13 13:45:36.578258+00	2025-06-13 16:44:36.578258+00	f	\N	\N	2025-06-13 13:45:36.576548+00	2025-06-13 13:45:36.576548+00
244d4867-fad2-44a4-aa5a-375e422c3a69	3	\N	魔法学校の生徒リオ_648	6	47	visiting	\N	2025-06-13 13:46:47.670422+00	2025-06-13 16:18:47.670422+00	f	\N	\N	2025-06-13 13:46:47.668924+00	2025-06-13 13:46:47.668924+00
f538145a-868f-4c7b-b6d5-9c5ec9943759	2	\N	見習い狩人サラ_102	7	48	visiting	\N	2025-06-13 13:51:21.685253+00	2025-06-13 16:08:21.685253+00	f	\N	\N	2025-06-13 13:51:21.683562+00	2025-06-13 13:51:21.683562+00
37abc9f7-8520-4528-9fd9-004a43c62dfd	3	\N	魔法学校の生徒リオ_179	4	11	visiting	\N	2025-06-13 13:51:21.685253+00	2025-06-13 16:50:21.685253+00	f	\N	\N	2025-06-13 13:51:21.683562+00	2025-06-13 13:51:21.683562+00
164f24bc-f48a-4b64-a005-4f0deeaa4f54	2	\N	見習い狩人サラ_451	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:26:47.360832+00	2025-06-13 14:52:11.046295+00
36ce6a20-4bb1-4794-9f8e-00bad1bf8754	2	\N	見習い狩人サラ_712	8	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:54.521229+00	2025-06-13 14:52:11.046295+00
6dd7a709-1fe3-4ceb-8828-3ce5a372cadc	3	\N	魔法学校の生徒リオ_140	4	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:40:06.609856+00	2025-06-13 14:52:11.046295+00
8e6db9cb-98f2-43d1-95b4-7c94c8fffeed	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_416	7	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:28:57.094355+00	2025-06-13 14:52:11.046295+00
a67ed1c4-446a-4786-8973-7b9490c6f0e5	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_43	8	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:28:57.094355+00	2025-06-13 14:52:11.046295+00
a8ebb7ce-ec89-46ba-806d-203fc958e977	2	\N	見習い狩人サラ_531	7	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:37.502269+00	2025-06-13 14:52:11.046295+00
d5033b71-a37a-4b45-8459-28e893d2a31b	3	\N	魔法学校の生徒リオ_653	4	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:40:06.609856+00	2025-06-13 14:52:11.046295+00
a91666fa-81d6-4b6f-a6bd-44c2311389f3	3	\N	魔法学校の生徒リオ_713	5	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:42:18.531172+00	2025-06-13 14:53:40.958658+00
f7991335-354e-4321-b63b-054f95d056bb	2	\N	見習い狩人サラ_112	9	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:57:54.521229+00	2025-06-13 14:54:10.951855+00
c3f1bcfc-ae24-40eb-9095-dc2acddb960e	2	\N	見習い狩人サラ_1	6	2	visiting	\N	2025-06-13 14:56:11.066695+00	2025-06-13 16:14:11.066695+00	f	\N	\N	2025-06-13 14:56:11.06507+00	2025-06-13 14:56:11.06507+00
1cb2d18b-f41c-4b54-953c-b1a152edf055	2	\N	見習い狩人サラ_168	7	29	visiting	\N	2025-06-13 15:00:41.021097+00	2025-06-13 17:42:41.021097+00	f	\N	\N	2025-06-13 15:00:41.019809+00	2025-06-13 15:00:41.019809+00
4717a884-cc3b-4ac4-ba64-78fc18abc03f	3	\N	魔法学校の生徒リオ_793	5	0	visiting	\N	2025-06-13 15:00:41.021097+00	2025-06-13 15:53:41.021097+00	f	\N	\N	2025-06-13 15:00:41.019809+00	2025-06-13 15:00:41.019809+00
42755314-ea14-48a7-9fe8-2fb10b2fc956	2	\N	見習い狩人サラ_364	8	19	visiting	\N	2025-06-13 15:01:51.696776+00	2025-06-13 18:00:51.696776+00	f	\N	\N	2025-06-13 15:01:51.695661+00	2025-06-13 15:01:51.695661+00
39ce3904-47c1-45a0-ab4a-2ff62ecd7449	3	\N	魔法学校の生徒リオ_32	7	32	visiting	\N	2025-06-13 15:05:09.100986+00	2025-06-13 16:56:09.100986+00	f	\N	\N	2025-06-13 15:05:09.099215+00	2025-06-13 15:05:09.099215+00
3fafe14f-0a52-44d5-bd74-d5d7263309ea	3	\N	魔法学校の生徒リオ_826	7	49	visiting	\N	2025-06-13 15:05:09.100986+00	2025-06-13 16:04:09.100986+00	f	\N	\N	2025-06-13 15:05:09.099215+00	2025-06-13 15:05:09.099215+00
c184c344-6621-4cbd-bf5f-ec264f04b786	2	\N	見習い狩人サラ_221	9	23	visiting	\N	2025-06-13 15:05:09.100986+00	2025-06-13 16:57:09.100986+00	f	\N	\N	2025-06-13 15:05:09.099215+00	2025-06-13 15:05:09.099215+00
42818db1-ea86-4c34-b5ba-4b0dc31139d2	2	\N	見習い狩人サラ_376	8	3	visiting	\N	2025-06-13 15:05:25.662992+00	2025-06-13 17:08:25.662992+00	f	\N	\N	2025-06-13 15:05:25.662027+00	2025-06-13 15:05:25.662027+00
b67451fd-af44-495a-8051-b4d49be380d9	3	\N	魔法学校の生徒リオ_658	6	11	visiting	\N	2025-06-13 15:05:38.752474+00	2025-06-13 17:09:38.752474+00	f	\N	\N	2025-06-13 15:05:38.751453+00	2025-06-13 15:05:38.751453+00
1a3c6620-6ebd-4bc3-a6ea-f701663f9a96	2	\N	見習い狩人サラ_595	10	40	visiting	\N	2025-06-13 15:05:38.752474+00	2025-06-13 16:46:38.752474+00	f	\N	\N	2025-06-13 15:05:38.751453+00	2025-06-13 15:05:38.751453+00
5ef72eda-64d9-4e06-912e-b3c10a3409bf	3	\N	魔法学校の生徒リオ_687	6	7	visiting	\N	2025-06-13 15:08:21.444847+00	2025-06-13 15:59:21.444847+00	f	\N	\N	2025-06-13 15:08:21.443559+00	2025-06-13 15:08:21.443559+00
0652f999-99f8-45e7-a55c-7705257063db	2	\N	見習い狩人サラ_985	8	41	visiting	\N	2025-06-13 15:08:21.444847+00	2025-06-13 16:20:21.444847+00	f	\N	\N	2025-06-13 15:08:21.443559+00	2025-06-13 15:08:21.443559+00
3617f225-274d-4077-a771-57ca31521794	2	\N	見習い狩人サラ_503	6	33	visiting	\N	2025-06-13 15:08:21.444847+00	2025-06-13 17:39:21.444847+00	f	\N	\N	2025-06-13 15:08:21.443559+00	2025-06-13 15:08:21.443559+00
59b7a923-1daa-4557-a115-87e370898b42	3	\N	魔法学校の生徒リオ_295	5	47	visiting	\N	2025-06-13 15:10:21.456126+00	2025-06-13 17:10:21.456126+00	f	\N	\N	2025-06-13 15:10:21.455386+00	2025-06-13 15:10:21.455386+00
b35b768a-ab4c-477c-85f3-a984c1ca305e	2	\N	見習い狩人サラ_139	7	28	visiting	\N	2025-06-13 15:10:21.456126+00	2025-06-13 17:10:21.456126+00	f	\N	\N	2025-06-13 15:10:21.455386+00	2025-06-13 15:10:21.455386+00
038525a7-3de2-4616-8ca5-22f86e34bd3d	3	\N	魔法学校の生徒リオ_793	8	50	visiting	\N	2025-06-13 15:12:51.558625+00	2025-06-13 17:54:51.558625+00	f	\N	\N	2025-06-13 15:12:51.557882+00	2025-06-13 15:12:51.557882+00
27eb2ad2-a0cf-47cf-a9d2-914ee0d80bfa	3	\N	魔法学校の生徒リオ_652	6	26	visiting	\N	2025-06-13 15:12:51.558625+00	2025-06-13 16:28:51.558625+00	f	\N	\N	2025-06-13 15:12:51.557882+00	2025-06-13 15:12:51.557882+00
d3035bfb-97c2-40b1-bc11-d867dcb81501	2	\N	見習い狩人サラ_594	8	16	visiting	\N	2025-06-13 15:14:02.666021+00	2025-06-13 17:22:02.666021+00	f	\N	\N	2025-06-13 15:14:02.6649+00	2025-06-13 15:14:02.6649+00
8cb2870c-ff83-473f-8808-f3c951be0e6a	3	\N	魔法学校の生徒リオ_780	6	17	visiting	\N	2025-06-13 15:14:51.534672+00	2025-06-13 17:23:51.534672+00	f	\N	\N	2025-06-13 15:14:51.533694+00	2025-06-13 15:14:51.533694+00
b0b7008f-c448-4abc-b67b-5f8bbb8b5372	2	\N	見習い狩人サラ_360	7	12	visiting	\N	2025-06-13 15:16:21.565312+00	2025-06-13 17:06:21.565312+00	f	\N	\N	2025-06-13 15:16:21.543129+00	2025-06-13 15:16:21.543129+00
11c3f2f2-d2c3-4b91-a083-9307a072585b	2	\N	見習い狩人サラ_950	7	19	visiting	\N	2025-06-13 15:18:52.813122+00	2025-06-13 16:07:52.813122+00	f	\N	\N	2025-06-13 15:18:52.812068+00	2025-06-13 15:18:52.812068+00
b148a6aa-6ad9-4333-87d0-2c8e66979b96	2	\N	見習い狩人サラ_673	10	32	visiting	\N	2025-06-13 15:18:52.813122+00	2025-06-13 16:50:52.813122+00	f	\N	\N	2025-06-13 15:18:52.812068+00	2025-06-13 15:18:52.812068+00
f1a38c54-833b-4b23-8c47-9bf1ada978b5	2	\N	見習い狩人サラ_133	10	1	visiting	\N	2025-06-13 15:19:42.839386+00	2025-06-13 17:25:42.839386+00	f	\N	\N	2025-06-13 15:19:42.838041+00	2025-06-13 15:19:42.838041+00
d4c85ab6-9eb2-4966-a1fa-6ce1406557ee	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_860	8	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:28:57.094355+00	2025-06-13 15:20:03.900056+00
170bbe65-1bbf-4e9e-b0f1-69f1081a7833	3	\N	魔法学校の生徒リオ_376	6	19	visiting	\N	2025-06-13 15:21:04.011492+00	2025-06-13 16:27:04.011492+00	f	\N	\N	2025-06-13 15:21:04.010536+00	2025-06-13 15:21:04.010536+00
ea5b9637-64d6-4f22-80f3-a0b88e2eef33	3	\N	魔法学校の生徒リオ_960	8	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:42:18.531172+00	2025-06-13 15:21:33.900053+00
6ef8190d-2671-4805-994e-c4d3c8beedef	3	\N	魔法学校の生徒リオ_142	7	23	visiting	\N	2025-06-13 15:22:03.977083+00	2025-06-13 17:07:03.977083+00	f	\N	\N	2025-06-13 15:22:03.976323+00	2025-06-13 15:22:03.976323+00
b6c0be7b-1f52-4081-92fe-4948d545f950	3	\N	魔法学校の生徒リオ_535	8	15	visiting	\N	2025-06-13 15:23:04.141624+00	2025-06-13 18:18:04.141624+00	f	\N	\N	2025-06-13 15:23:04.139882+00	2025-06-13 15:23:04.139882+00
a1b6032e-ca46-4e4a-85d8-2eb8c3374a82	3	\N	魔法学校の生徒リオ_155	7	3	visiting	\N	2025-06-13 15:23:04.141624+00	2025-06-13 16:56:04.141624+00	f	\N	\N	2025-06-13 15:23:04.139882+00	2025-06-13 15:23:04.139882+00
231d8ea4-0bf0-4332-90a3-a6cb39304261	2	\N	見習い狩人サラ_211	8	46	visiting	\N	2025-06-13 15:24:34.031644+00	2025-06-13 17:00:34.031644+00	f	\N	\N	2025-06-13 15:24:34.030619+00	2025-06-13 15:24:34.030619+00
e487549f-a22f-4f08-88b2-510718a4ca62	2	\N	見習い狩人サラ_816	9	12	visiting	\N	2025-06-13 15:24:34.031644+00	2025-06-13 17:31:34.031644+00	f	\N	\N	2025-06-13 15:24:34.030619+00	2025-06-13 15:24:34.030619+00
7107970f-de2d-4d5f-aa93-bb9385fd6761	3	\N	魔法学校の生徒リオ_766	7	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:37:36.627991+00	2025-06-13 15:32:06.199771+00
f3230f98-50e5-4421-ae80-5b67c3d4b6ce	2	\N	見習い狩人サラ_553	7	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:39:06.518564+00	2025-06-13 15:38:06.660165+00
fea8e6c1-b79a-422f-a206-7c8f8397c367	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_379	7	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:56.97432+00	2025-06-13 07:36:15.893861+00
bf2e3ce7-306b-41fd-9a57-57f2073ea00e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_810	7	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:10.395299+00	2025-06-13 07:40:15.94835+00
c12d37f3-c849-4004-982a-0fb72bb6ab10	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_932	7	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:56.80998+00	2025-06-13 07:41:05.522922+00
c19601bc-e6c8-4537-8782-8b4b0328cdfb	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_285	10	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:26.822321+00	2025-06-13 07:41:54.328166+00
e7427b26-7e39-4988-8bc5-30558112b2f7	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_737	3	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:27.366818+00	2025-06-13 07:44:54.296961+00
3a1a0062-3653-4c08-a168-4f4857174755	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_778	5	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:56.882292+00	2025-06-13 07:45:24.348443+00
b74cb702-5a38-4572-8933-57bb30194960	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_90	5	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:11.847328+00	2025-06-13 07:45:24.348443+00
b7d56235-43cf-4065-96f6-e7687e627e9a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_354	4	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:03:14.279199+00	2025-06-13 04:55:26.673482+00
916a01b9-6dc0-403a-ac16-47fee3046686	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_815	7	19	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:54:26.851885+00	2025-06-13 08:57:24.810807+00
6942d91c-2362-46fe-a566-a7df514d5ac8	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_941	8	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:56.837783+00	2025-06-13 05:45:14.335608+00
cb57b5b0-977f-402b-bf3d-9d1d3adcd4ad	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_175	3	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:12.078182+00	2025-06-13 05:50:23.937851+00
5041a910-abd9-46dd-ab2c-1b97da5a889b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_543	6	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:26.822321+00	2025-06-13 05:52:53.95802+00
18a4fdd8-6da6-4f98-8025-bf698a105028	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_937	3	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:10.395299+00	2025-06-13 05:56:24.275187+00
d54d91f7-8ac8-4b37-9f21-93c71bc2c09a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_499	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:26.851885+00	2025-06-13 06:04:43.120378+00
685e7c60-9586-44a6-afe0-e11a4643c754	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_250	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:14.015444+00	2025-06-13 06:12:38.73408+00
5450de7b-9624-4d8e-a47e-df0504c18a3d	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_540	5	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:10.395299+00	2025-06-13 06:14:16.263497+00
f35ff5f6-e917-4c70-b301-9c457f5a68b9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_159	7	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:56.785477+00	2025-06-13 06:19:18.694835+00
88f08ec9-16e6-4a0c-ba02-2189e5b4d269	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_220	6	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:56.882292+00	2025-06-13 06:23:18.888133+00
651148f5-7c9e-45b9-b1ce-b4cd2c99b4c5	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_308	8	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:56.793142+00	2025-06-13 06:25:18.94322+00
a3d9042c-1d7a-4103-8ca6-c69c1ee2146b	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_974	9	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:56.785477+00	2025-06-13 06:25:18.94322+00
13056346-246b-4333-84ca-e18939a6c9a0	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_37	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:56.785477+00	2025-06-13 06:30:24.739499+00
06bde693-8029-4cca-9c82-58977a123c2c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_167	5	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:26.829076+00	2025-06-13 06:30:54.754816+00
9b36f42f-19c5-4772-8537-94482db0dd43	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_636	10	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:10.395299+00	2025-06-13 06:35:24.999344+00
520ace75-7cb7-4dea-aaaf-a77ec889ad60	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_223	6	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:26.818952+00	2025-06-13 06:35:54.742557+00
54d53d04-e6f2-473b-84b0-44631631c9f7	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_589	6	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:27.366818+00	2025-06-13 06:36:54.768439+00
063c453e-e4b2-4d26-a6a5-81d78d414e36	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_480	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:26.851885+00	2025-06-13 06:42:46.82754+00
504ab010-6684-4152-90b0-bbbb686426f8	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_426	5	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:14.015444+00	2025-06-13 06:42:46.82754+00
d12e7a8b-d739-4b51-8920-fd5c6031bce8	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_23	7	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:26.829076+00	2025-06-13 06:42:46.82754+00
05d07317-8eae-46e4-8eec-5bf6aff34d7a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_939	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:12.078182+00	2025-06-13 07:13:13.236721+00
06c3ad4e-d663-4657-ac9b-bddc53340afc	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_76	6	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:56.837783+00	2025-06-13 07:13:13.236721+00
507d1d6b-5baf-482e-b415-f4ca8ea52d7e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_599	8	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:59.911178+00	2025-06-13 07:13:13.236721+00
5bf31770-17ba-4edc-9e9e-8e01ac338322	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_136	7	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:26.829076+00	2025-06-13 07:13:13.236721+00
77859666-74cf-4bba-a862-062dc1047e31	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_507	6	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:14.015444+00	2025-06-13 07:13:32.015137+00
019c4c09-d7c1-4c17-80ac-809fecd1050d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_223	10	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:56.80998+00	2025-06-13 07:21:02.821192+00
f4218b0a-cd36-40d4-b927-ca7464a97e67	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_909	7	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:52:56.882292+00	2025-06-13 07:22:13.821781+00
03a126c3-5d5a-4bf6-94c0-21d4e36c7d98	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_840	7	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:12.078182+00	2025-06-13 07:24:21.980618+00
b40c894b-5174-4d47-a77a-e3379d131b82	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_950	6	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:56.97432+00	2025-06-13 07:24:21.980618+00
7fc30bef-ec04-4a67-80b8-f3d8930cab4e	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_53	5	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:56.80998+00	2025-06-13 07:26:03.655881+00
8b4fcd81-c0eb-423c-8651-d9999bf1659d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_308	6	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:11.847328+00	2025-06-13 07:26:33.626641+00
09fd3599-fef7-4945-9dc6-28331895f1ea	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_598	10	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:14.015444+00	2025-06-13 07:27:33.638409+00
539b03a4-8ad3-44b7-9db5-f0c34958ca55	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_678	3	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:10.395299+00	2025-06-13 07:28:33.633003+00
84bbb001-754a-4f6c-b23a-693f0b560f2d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_573	3	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:12.078182+00	2025-06-13 07:28:33.633003+00
363453cd-92eb-4b94-b56f-0cd3e19c5c48	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_140	6	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:59.911178+00	2025-06-13 07:29:03.646949+00
f66631c7-7a6b-4da3-9186-601a9aac9369	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_565	6	44	returning	\N	\N	\N	f	\N	\N	2025-06-13 04:49:56.785477+00	2025-06-13 08:57:24.833797+00
8c336b7e-1ec2-4658-81f3-26da996f0d6d	2	\N	見習い狩人サラ_468	9	15	visiting	\N	2025-06-13 13:14:17.161281+00	2025-06-13 16:03:17.161281+00	f	\N	\N	2025-06-13 13:14:17.160295+00	2025-06-13 13:14:17.160295+00
9fb56290-bd0e-46c5-94f4-f3c374c32bd8	1	\N	村の少年タム_168	3	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:45.409626+00	2025-06-13 14:56:10.953709+00
9e7023ad-78dd-4e05-9c3c-35468d322282	3	\N	魔法学校の生徒リオ_671	5	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:45.409626+00	2025-06-13 15:00:10.92974+00
b49a5162-0a1d-4c99-b023-a3e9c82c993c	3	\N	魔法学校の生徒リオ_999	6	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:58:16.049353+00	2025-06-13 15:07:21.343579+00
4f8bcff3-8d5d-4915-bb4a-be6aeb6b6cb7	2	\N	見習い狩人サラ_495	7	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:46:11.2618+00	2025-06-13 15:12:21.470219+00
74580b3e-d9c3-408a-bd04-3040d350aa35	3	\N	魔法学校の生徒リオ_388	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:46:11.2618+00	2025-06-13 15:28:33.886859+00
6a0d00e1-fb01-47d5-ade2-56a340162394	3	\N	魔法学校の生徒リオ_145	5	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:15.460044+00	2025-06-13 15:36:34.186179+00
28d4c558-dfed-49a4-9177-923a250990ee	2	\N	見習い狩人サラ_969	7	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:15.460044+00	2025-06-13 15:39:33.940158+00
24f4923f-5ed5-468d-935c-9202ce6af5f6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_420	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:30.149939+00	2025-06-13 06:04:43.120378+00
8cef6bc7-d0d9-4595-87bb-864f4bcbb66c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_507	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:30.149939+00	2025-06-13 06:32:54.779117+00
c4a47cf9-0163-4b8a-8be9-eb2e72fa4d2f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_318	6	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:00.44464+00	2025-06-13 06:34:24.736433+00
1e03be91-11ab-490e-9135-3820c20c2b10	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_666	5	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:26.818952+00	2025-06-13 06:34:54.744074+00
53cf9465-025c-4c4c-b381-96417b970db1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_53	3	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:00.44464+00	2025-06-13 07:13:13.236721+00
a2b910bb-ff95-4091-b450-b254d1e9db14	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_578	10	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:51.352009+00	2025-06-13 07:13:13.236721+00
4e9206b0-57ba-4597-9a56-dd17151d0d18	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_829	5	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:30.149939+00	2025-06-13 07:25:33.627611+00
c4855da8-9b48-4514-9a51-fcb44c9db4dd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_449	7	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:30.149939+00	2025-06-13 07:30:33.639783+00
1e0c0885-cbc5-47c7-8e63-ecfe4a15275b	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_953	6	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:00.44464+00	2025-06-13 07:37:15.901204+00
42d9eea7-8484-4d75-adb8-406573e3b83e	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_295	4	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:51.352009+00	2025-06-13 07:44:54.296961+00
e4a331d6-2802-408c-aa09-d564cb27a204	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_691	5	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:58:00.44464+00	2025-06-13 07:58:22.182772+00
3b7ffafa-11b5-4064-bfa3-f66c1a87fc46	3	\N	魔法学校の生徒リオ_416	6	50	visiting	\N	2025-06-13 13:18:17.006645+00	2025-06-13 16:02:17.006645+00	f	\N	\N	2025-06-13 13:18:17.005603+00	2025-06-13 13:18:17.005603+00
85cfd013-ea77-488b-8481-d3eb4bd75cfb	3	\N	魔法学校の生徒リオ_852	6	7	visiting	\N	2025-06-13 13:23:17.154026+00	2025-06-13 16:07:17.154026+00	f	\N	\N	2025-06-13 13:23:17.153161+00	2025-06-13 13:23:17.153161+00
f9d32f3d-686a-4af8-aa28-60cdee717618	3	\N	魔法学校の生徒リオ_34	4	34	visiting	\N	2025-06-13 13:23:17.154026+00	2025-06-13 15:49:17.154026+00	f	\N	\N	2025-06-13 13:23:17.153161+00	2025-06-13 13:23:17.153161+00
6a9a4a5f-e196-4ade-b641-2402f56b1007	3	\N	魔法学校の生徒リオ_114	8	10	visiting	\N	2025-06-13 13:27:02.281431+00	2025-06-13 16:11:02.281431+00	f	\N	\N	2025-06-13 13:27:02.279043+00	2025-06-13 13:27:02.279043+00
98cf9608-46ae-4117-8a71-a3658c237dd8	2	\N	見習い狩人サラ_716	10	14	visiting	\N	2025-06-13 13:30:53.302654+00	2025-06-13 16:12:53.302654+00	f	\N	\N	2025-06-13 13:30:53.300513+00	2025-06-13 13:30:53.300513+00
7ebbc6ef-c65b-48a0-996f-0bcfaabaedc3	2	\N	見習い狩人サラ_395	8	43	visiting	\N	2025-06-13 13:47:28.334203+00	2025-06-13 15:51:28.334203+00	f	\N	\N	2025-06-13 13:47:28.333134+00	2025-06-13 13:47:28.333134+00
56867303-90ed-4ef6-898b-b9b5c0a087b4	2	\N	見習い狩人サラ_572	7	21	visiting	\N	2025-06-13 13:47:28.334203+00	2025-06-13 16:46:28.334203+00	f	\N	\N	2025-06-13 13:47:28.333134+00	2025-06-13 13:47:28.333134+00
b7097fdb-1ff7-4351-a8be-2ed021243bc6	2	\N	見習い狩人サラ_542	8	17	visiting	\N	2025-06-13 13:47:28.334203+00	2025-06-13 16:13:28.334203+00	f	\N	\N	2025-06-13 13:47:28.333134+00	2025-06-13 13:47:28.333134+00
01b39766-fecd-4fe4-a662-1d4c05277873	2	\N	見習い狩人サラ_420	6	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:27:02.279043+00	2025-06-13 14:52:11.046295+00
0ed92a3f-29a3-495f-85f6-3b8a1d06332c	2	\N	見習い狩人サラ_692	6	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:46:41.335668+00	2025-06-13 14:52:11.046295+00
110e5391-7043-4143-8812-ac72bb74af25	2	\N	見習い狩人サラ_130	10	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:18:17.005603+00	2025-06-13 14:52:11.046295+00
2dbbf6cc-8b83-466e-aab1-cb01906d2fb0	2	\N	見習い狩人サラ_139	8	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:27:17.177829+00	2025-06-13 14:52:11.046295+00
510cf527-3940-4e21-82c6-d3e2256a3746	3	\N	魔法学校の生徒リオ_557	4	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:05.579221+00	2025-06-13 14:52:11.046295+00
7b2e8562-b75d-47eb-ab92-5b6f142eb00c	2	\N	見習い狩人サラ_517	6	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:45.549791+00	2025-06-13 14:52:11.046295+00
816da673-6d03-4f00-a6e3-158d0c06c45b	2	\N	見習い狩人サラ_539	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:45.549791+00	2025-06-13 14:52:11.046295+00
84285c34-b40a-4065-bd79-a30ae6d748bb	3	\N	魔法学校の生徒リオ_769	4	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:47.112554+00	2025-06-13 14:52:11.046295+00
d02c4bf6-426d-4c60-adad-45adfbae53ca	2	\N	見習い狩人サラ_813	9	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:27:02.279043+00	2025-06-13 14:53:10.911903+00
a0d28466-fead-4c42-84a2-2f57a178e04f	3	\N	魔法学校の生徒リオ_397	4	45	visiting	\N	2025-06-13 14:56:40.253572+00	2025-06-13 16:09:40.253572+00	f	\N	\N	2025-06-13 14:56:40.248153+00	2025-06-13 14:56:40.248153+00
140fd520-9016-491b-9ee3-038c189b3ab2	2	\N	見習い狩人サラ_839	9	27	visiting	\N	2025-06-13 14:56:40.253572+00	2025-06-13 15:54:40.253572+00	f	\N	\N	2025-06-13 14:56:40.248153+00	2025-06-13 14:56:40.248153+00
da327d64-481f-4f4a-a26c-db1c5427f820	3	\N	魔法学校の生徒リオ_477	8	36	visiting	\N	2025-06-13 14:56:40.253572+00	2025-06-13 17:53:40.253572+00	f	\N	\N	2025-06-13 14:56:40.248153+00	2025-06-13 14:56:40.248153+00
8afb6970-cf34-4896-91ac-65bf3868d4ee	2	\N	見習い狩人サラ_904	8	46	visiting	\N	2025-06-13 15:02:41.048024+00	2025-06-13 15:54:41.048024+00	f	\N	\N	2025-06-13 15:02:41.047184+00	2025-06-13 15:02:41.047184+00
b8bdc96f-cc51-4c41-b3f6-41a7e0c882c3	2	\N	見習い狩人サラ_348	7	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:30:53.300513+00	2025-06-13 15:03:10.915032+00
0bbe4279-3f94-46a3-bf05-028c92c66dcf	2	\N	見習い狩人サラ_42	9	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:24:17.437727+00	2025-06-13 15:04:31.785898+00
558804d6-38b7-43b8-bf11-deaf6d808abc	3	\N	魔法学校の生徒リオ_169	5	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:35:07.902247+00	2025-06-13 15:04:31.785898+00
3178e71a-6444-4bf7-9dac-f73c29ab4e1f	3	\N	魔法学校の生徒リオ_810	4	6	visiting	\N	2025-06-13 15:04:31.947757+00	2025-06-13 16:11:31.947757+00	f	\N	\N	2025-06-13 15:04:31.946705+00	2025-06-13 15:04:31.946705+00
06c858fd-3df6-4b77-8683-470f6fa55380	3	\N	魔法学校の生徒リオ_811	6	44	visiting	\N	2025-06-13 15:05:01.669875+00	2025-06-13 17:08:01.669875+00	f	\N	\N	2025-06-13 15:05:01.668754+00	2025-06-13 15:05:01.668754+00
9fdeaf61-e443-463d-a359-b718cf0639ca	2	\N	見習い狩人サラ_278	7	39	visiting	\N	2025-06-13 15:05:01.669875+00	2025-06-13 16:28:01.669875+00	f	\N	\N	2025-06-13 15:05:01.668754+00	2025-06-13 15:05:01.668754+00
37670a51-426c-4e63-8f62-2c007c0e61f8	2	\N	見習い狩人サラ_152	8	8	visiting	\N	2025-06-13 15:05:01.669875+00	2025-06-13 16:40:01.669875+00	f	\N	\N	2025-06-13 15:05:01.668754+00	2025-06-13 15:05:01.668754+00
29e62f6e-c891-4e90-9940-08a016d3b350	2	\N	見習い狩人サラ_908	7	19	visiting	\N	2025-06-13 15:06:06.593218+00	2025-06-13 17:52:06.593218+00	f	\N	\N	2025-06-13 15:06:06.592298+00	2025-06-13 15:06:06.592298+00
c21ec8c6-4450-4230-827c-77d76a210adb	2	\N	見習い狩人サラ_497	10	27	visiting	\N	2025-06-13 15:06:06.593218+00	2025-06-13 16:49:06.593218+00	f	\N	\N	2025-06-13 15:06:06.592298+00	2025-06-13 15:06:06.592298+00
104a1819-4a24-4918-aad3-4aae3b686e3c	3	\N	魔法学校の生徒リオ_365	8	49	visiting	\N	2025-06-13 15:06:06.593218+00	2025-06-13 15:51:06.593218+00	f	\N	\N	2025-06-13 15:06:06.592298+00	2025-06-13 15:06:06.592298+00
90e0b226-55c0-4a12-98a0-5e42884c96b8	2	\N	見習い狩人サラ_281	9	36	visiting	\N	2025-06-13 15:06:38.762712+00	2025-06-13 17:53:38.762712+00	f	\N	\N	2025-06-13 15:06:38.761829+00	2025-06-13 15:06:38.761829+00
dcbb2b34-b79b-439c-9807-733f4c1df3d1	2	\N	見習い狩人サラ_100	10	42	visiting	\N	2025-06-13 15:06:38.762712+00	2025-06-13 17:58:38.762712+00	f	\N	\N	2025-06-13 15:06:38.761829+00	2025-06-13 15:06:38.761829+00
74875282-b631-4542-8244-9c86be129ba3	3	\N	魔法学校の生徒リオ_247	5	3	visiting	\N	2025-06-13 15:07:00.629439+00	2025-06-13 17:17:00.629439+00	f	\N	\N	2025-06-13 15:07:00.62791+00	2025-06-13 15:07:00.62791+00
882c7fe0-830d-45ce-a8c1-6b5035ff3db8	2	\N	見習い狩人サラ_122	6	41	visiting	\N	2025-06-13 15:07:00.629439+00	2025-06-13 16:23:00.629439+00	f	\N	\N	2025-06-13 15:07:00.62791+00	2025-06-13 15:07:00.62791+00
3cede37e-9408-4d27-bebd-5a5b8962fb19	3	\N	魔法学校の生徒リオ_834	7	38	visiting	\N	2025-06-13 15:07:08.748471+00	2025-06-13 17:56:08.748471+00	f	\N	\N	2025-06-13 15:07:08.747228+00	2025-06-13 15:07:08.747228+00
1d522546-baaf-4e49-8feb-f3fc17b58ca7	2	\N	見習い狩人サラ_39	10	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:30:53.300513+00	2025-06-13 15:14:21.476094+00
c9447b25-c5d2-4880-9674-9f4ccda139bf	2	\N	見習い狩人サラ_990	10	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:32:23.017676+00	2025-06-13 15:15:51.462837+00
c1c2ac73-ab39-4dc1-ba0e-d987694eb1a5	3	\N	魔法学校の生徒リオ_869	4	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:21:17.156043+00	2025-06-13 15:17:33.896846+00
18985d68-13e5-4081-9299-76490e9500df	3	\N	魔法学校の生徒リオ_96	8	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:17:44.923972+00	2025-06-13 15:19:03.904675+00
4bf8ce5f-1902-4460-9424-0246f9075a38	1	\N	村の少年タム_201	4	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:45.549791+00	2025-06-13 15:27:03.894926+00
e1563cf9-185d-45b5-a349-7c817e2278f7	3	\N	魔法学校の生徒リオ_144	6	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:05.579221+00	2025-06-13 15:27:33.906449+00
5a8dca0a-14d1-483f-a646-7903e454c27d	2	\N	見習い狩人サラ_912	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:32:23.017676+00	2025-06-13 15:28:33.886859+00
51c053e8-64fc-4b69-8e25-2bf01a62b4f6	1	\N	村の少年タム_959	3	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:05.579221+00	2025-06-13 15:34:33.91938+00
4aa10c01-d17a-4db2-8315-138aefcda0e8	2	\N	見習い狩人サラ_840	9	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:51:51.640254+00	2025-06-13 15:44:03.950411+00
3ebdfcc6-b98a-4fe4-9928-fc963ea1f951	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_918	8	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:14.548658+00	2025-06-13 06:17:18.658965+00
e40fd473-4b63-4e18-b4bf-960645a25807	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_920	6	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:00.371059+00	2025-06-13 06:24:18.665801+00
99e12b36-1086-42f7-beaa-fbdb7a989650	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_820	6	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:30.218581+00	2025-06-13 06:24:48.70658+00
5252ad39-3539-466b-b873-ae4e0aef5f6b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_592	6	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:14.548658+00	2025-06-13 06:26:18.693372+00
ce2edae4-ea03-405d-b607-c18f303a74fd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_656	4	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:00.34537+00	2025-06-13 06:28:24.792823+00
df744345-702a-4065-ba28-cce077960614	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_854	5	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:14.548658+00	2025-06-13 06:35:24.999344+00
6e0bc0c4-559a-4399-88de-d5abf1b64591	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_653	7	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:00.3118+00	2025-06-13 06:42:46.82754+00
13ae1443-b6c6-4091-85f0-dac1aa1f639c	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_393	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:32.034318+00	2025-06-13 07:13:13.236721+00
22609406-60d0-4b21-bb79-46b8a700dc14	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_489	5	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:32.034318+00	2025-06-13 07:13:13.236721+00
2bfbe795-e845-4ed9-ade5-373a2c680959	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_685	10	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:56:26.800857+00	2025-06-13 07:13:13.236721+00
3121a00d-cbaf-4836-aec2-e0a16fbf6490	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_253	6	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:14.548658+00	2025-06-13 07:13:13.236721+00
3fc7c083-bd0e-4eef-9b47-eb53b226bf6c	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_412	4	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:56:26.800857+00	2025-06-13 07:13:13.236721+00
4d3c0b5b-a166-40cc-a4c1-307ee0d6f82e	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_219	3	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:30.218581+00	2025-06-13 07:13:13.236721+00
71ca2dc8-de93-477c-96ec-38d9dc097c60	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_361	5	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:32.034318+00	2025-06-13 07:13:13.236721+00
93d5fccc-7aa4-4e39-98e4-3be2c903ffac	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_63	10	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:56:26.800857+00	2025-06-13 07:13:13.236721+00
70f063e9-d7bc-427b-9b4c-4cdf2c3cd22d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_161	7	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:00.34537+00	2025-06-13 07:25:03.702286+00
760701ff-5dba-4e9c-a999-4a4948a6294c	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_25	4	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:00.3118+00	2025-06-13 07:27:03.666227+00
5efb5843-3f1b-4baa-aa00-ffe7684c77e9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_373	6	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:00.371059+00	2025-06-13 07:31:03.639476+00
e1dda3e4-92b0-466b-a6ce-314596e7a5f9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_855	10	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:14.548658+00	2025-06-13 07:35:15.615828+00
bd86a936-b2d6-43f9-bb8a-18a87de53129	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_417	10	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:30.218581+00	2025-06-13 07:37:45.877567+00
1188eb30-429d-4f76-9434-0c7ae4b5913e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_422	10	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:56.793142+00	2025-06-13 07:41:05.522922+00
75d4f853-6485-4940-a557-727635c78b67	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_680	5	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:21.44335+00	2025-06-13 07:46:22.197102+00
2e2de494-2c21-42f9-8be9-85606059574d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_943	6	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:56.793142+00	2025-06-13 07:49:22.156932+00
5214f944-9fe2-43d9-80d7-29e49f97c0fe	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_23	4	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:00.3118+00	2025-06-13 07:53:06.782639+00
969afd0a-c9c7-434c-82c2-48b29ab4396d	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_518	6	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:57:21.44335+00	2025-06-13 07:57:22.171596+00
7ac8399c-62c3-4776-93a2-13243a11025c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_328	6	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:00.3118+00	2025-06-13 07:58:22.182772+00
f2856490-8501-4884-bf1f-3a5740cda082	2	\N	見習い狩人サラ_179	6	47	visiting	\N	2025-06-13 12:49:33.24275+00	2025-06-13 15:47:33.24275+00	f	\N	\N	2025-06-13 12:49:33.241344+00	2025-06-13 12:49:33.241344+00
3115b563-ad4e-4eb4-a7e4-b99eea0a80f2	1	\N	村の少年タム_325	7	50	visiting	\N	2025-06-13 12:59:15.819488+00	2025-06-13 15:51:15.819488+00	f	\N	\N	2025-06-13 12:59:15.818257+00	2025-06-13 12:59:15.818257+00
33d29014-fb7c-4bcd-a991-89dde316f761	3	\N	魔法学校の生徒リオ_533	6	0	visiting	\N	2025-06-13 13:18:31.978462+00	2025-06-13 15:54:31.978462+00	f	\N	\N	2025-06-13 13:18:31.977391+00	2025-06-13 13:18:31.977391+00
6f5b2d14-6707-46f7-a5d4-08eacc7d5f7f	2	\N	見習い狩人サラ_237	9	2	visiting	\N	2025-06-13 13:19:47.065779+00	2025-06-13 16:10:47.065779+00	f	\N	\N	2025-06-13 13:19:47.064587+00	2025-06-13 13:19:47.064587+00
efd0d42f-1f5c-4f41-898a-526cf1c88cac	3	\N	魔法学校の生徒リオ_663	5	16	visiting	\N	2025-06-13 13:20:17.011118+00	2025-06-13 16:04:17.011118+00	f	\N	\N	2025-06-13 13:20:17.005158+00	2025-06-13 13:20:17.005158+00
5b064b1b-bc7f-400e-895a-dfda1be8768f	3	\N	魔法学校の生徒リオ_422	4	40	visiting	\N	2025-06-13 13:20:17.011118+00	2025-06-13 16:00:17.011118+00	f	\N	\N	2025-06-13 13:20:17.005158+00	2025-06-13 13:20:17.005158+00
bca0292f-9723-46e8-be63-b8b064c71d3f	2	\N	見習い狩人サラ_604	8	25	visiting	\N	2025-06-13 13:20:47.101877+00	2025-06-13 16:08:47.101877+00	f	\N	\N	2025-06-13 13:20:47.100562+00	2025-06-13 13:20:47.100562+00
19a2c954-4441-42e7-a6ca-8a1baecfd0eb	2	\N	見習い狩人サラ_101	10	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:17:17.111303+00	2025-06-13 14:52:17.744847+00
d7909d08-29c8-4264-b47f-2301b2906660	3	\N	魔法学校の生徒リオ_663	4	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:47.100562+00	2025-06-13 14:54:10.951855+00
7ed87991-5af7-45fa-9ca0-35a771e644d3	2	\N	見習い狩人サラ_462	6	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:10.553962+00	2025-06-13 15:01:10.945311+00
114e055f-3751-4ae8-803c-5a12d7730214	2	\N	見習い狩人サラ_951	8	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:14:19.828944+00	2025-06-13 15:05:25.516566+00
12825776-e59c-4e6e-b051-2becb0379f45	1	\N	村の少年タム_247	6	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:33.241344+00	2025-06-13 15:07:51.382242+00
0f498357-43b4-4dfd-9577-a09571ed4c72	2	\N	見習い狩人サラ_520	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:19:47.064587+00	2025-06-13 15:11:51.520475+00
2c237c63-b6ba-45be-aa54-57b103a90fba	3	\N	魔法学校の生徒リオ_409	5	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:47.271588+00	2025-06-13 15:18:03.963239+00
777cef0d-2fbd-4031-b077-316c55c30957	3	\N	魔法学校の生徒リオ_360	7	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:11.097182+00	2025-06-13 15:23:33.868293+00
b9dc2647-b948-4135-b970-1e593123dc00	2	\N	見習い狩人サラ_304	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:47.100562+00	2025-06-13 15:24:03.903062+00
72067c14-d61e-4bd9-8c09-ae9c9912c1e5	1	\N	村の少年タム_892	3	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:10.553962+00	2025-06-13 15:26:33.9524+00
a60c3a7b-1f11-4a96-9eac-363d66810db8	2	\N	見習い狩人サラ_259	9	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:40.629673+00	2025-06-13 15:29:03.92424+00
d62cdd9b-5533-4530-9e19-1461f4209e65	2	\N	見習い狩人サラ_469	10	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:47.271588+00	2025-06-13 15:43:03.978781+00
cb8273eb-bd99-457b-b8cd-cfb3c542b874	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_363	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:20.963008+00	2025-06-13 05:54:23.952023+00
efe072eb-9782-4469-adef-27f59d601ba2	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_584	8	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:20.963008+00	2025-06-13 06:43:31.166025+00
d5a5685c-06c2-41e7-90c6-13973e49cc9e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_103	8	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:20.963008+00	2025-06-13 07:13:13.236721+00
d0720624-0e0e-428a-bbf8-dbf751b2aee6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_748	7	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:59:20.963008+00	2025-06-13 07:27:33.638409+00
23bbbea1-34c3-4198-8174-ac1430f0e020	2	\N	見習い狩人サラ_822	8	40	visiting	\N	2025-06-13 13:12:15.394286+00	2025-06-13 15:59:15.394286+00	f	\N	\N	2025-06-13 13:12:15.393377+00	2025-06-13 13:12:15.393377+00
8a64a893-0de9-4631-ad91-7e3ba39a5abf	2	\N	見習い狩人サラ_149	6	20	visiting	\N	2025-06-13 13:12:15.394286+00	2025-06-13 15:51:15.394286+00	f	\N	\N	2025-06-13 13:12:15.393377+00	2025-06-13 13:12:15.393377+00
1ec09aa4-e804-4132-b312-56b3e020dc32	2	\N	見習い狩人サラ_80	7	0	visiting	\N	2025-06-13 13:14:47.15369+00	2025-06-13 15:46:47.15369+00	f	\N	\N	2025-06-13 13:14:47.152746+00	2025-06-13 13:14:47.152746+00
cd2f09b6-619d-4c40-9e6e-fc487885b69c	3	\N	魔法学校の生徒リオ_850	8	6	visiting	\N	2025-06-13 13:16:47.158552+00	2025-06-13 15:54:47.158552+00	f	\N	\N	2025-06-13 13:16:47.157464+00	2025-06-13 13:16:47.157464+00
d6af4616-2aad-4810-8d27-1e83685b86d0	3	\N	魔法学校の生徒リオ_335	6	21	visiting	\N	2025-06-13 13:16:47.158552+00	2025-06-13 16:09:47.158552+00	f	\N	\N	2025-06-13 13:16:47.157464+00	2025-06-13 13:16:47.157464+00
cb99c7a0-678a-4786-846e-e085a1ee0108	3	\N	魔法学校の生徒リオ_221	8	21	visiting	\N	2025-06-13 13:27:47.182725+00	2025-06-13 16:08:47.182725+00	f	\N	\N	2025-06-13 13:27:47.180135+00	2025-06-13 13:27:47.180135+00
45181512-fb4c-49f2-a678-1f2d0637ab27	2	\N	見習い狩人サラ_330	7	2	visiting	\N	2025-06-13 13:27:47.182725+00	2025-06-13 16:14:47.182725+00	f	\N	\N	2025-06-13 13:27:47.180135+00	2025-06-13 13:27:47.180135+00
37e0c8fd-c736-4a34-b597-c8be6c2b65de	1	\N	村の少年タム_45	5	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:50:10.541282+00	2025-06-13 13:38:36.727709+00
cd510238-c665-404b-a273-fbd3ec6dead3	1	\N	村の少年タム_441	5	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:16.119502+00	2025-06-13 13:46:36.438661+00
890bb019-eefe-4bc2-9be1-0d6265dfeb91	2	\N	見習い狩人サラ_747	9	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:54:45.444036+00	2025-06-13 13:47:53.668296+00
7cb00101-52f1-453b-ad02-86714b1a2c14	3	\N	魔法学校の生徒リオ_613	6	36	visiting	\N	2025-06-13 13:47:53.919065+00	2025-06-13 16:24:53.919065+00	f	\N	\N	2025-06-13 13:47:53.917939+00	2025-06-13 13:47:53.917939+00
a376f487-8ad4-4ef3-8e2a-01832585313e	2	\N	見習い狩人サラ_794	8	6	visiting	\N	2025-06-13 13:52:21.367129+00	2025-06-13 16:28:21.367129+00	f	\N	\N	2025-06-13 13:52:21.366202+00	2025-06-13 13:52:21.366202+00
854699dc-4955-4278-b905-29c200c06a97	2	\N	見習い狩人サラ_995	9	37	visiting	\N	2025-06-13 13:52:21.367129+00	2025-06-13 16:09:21.367129+00	f	\N	\N	2025-06-13 13:52:21.366202+00	2025-06-13 13:52:21.366202+00
3a225f80-7a43-4f84-b950-16a4e0c6325c	3	\N	魔法学校の生徒リオ_122	5	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:12:45.417177+00	2025-06-13 14:52:11.046295+00
551e13a5-b032-4691-990f-b8d22b9bcfbb	2	\N	見習い狩人サラ_209	10	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:10.570874+00	2025-06-13 14:52:11.046295+00
597437fd-6d37-4a3e-abbd-87f10abffa68	2	\N	見習い狩人サラ_956	9	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:10.570874+00	2025-06-13 14:52:11.046295+00
679c3eca-caeb-4c54-9f08-65b1d8c1eda9	3	\N	魔法学校の生徒リオ_428	5	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:50:10.541282+00	2025-06-13 14:52:11.046295+00
91d7edd0-e1c7-4c4b-820e-bc06e7365dc8	3	\N	魔法学校の生徒リオ_235	5	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:12:45.417177+00	2025-06-13 14:52:11.046295+00
94a833bf-4e5a-485d-a716-a8a3936d2280	3	\N	魔法学校の生徒リオ_172	5	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:47:53.917939+00	2025-06-13 14:52:11.046295+00
a3f01174-f273-4724-bd43-0d09120519d0	2	\N	見習い狩人サラ_632	7	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:14.887175+00	2025-06-13 14:52:11.046295+00
a42a9990-0073-4155-b051-6f0fab59df4f	2	\N	見習い狩人サラ_949	8	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:22:16.160804+00	2025-06-13 14:52:11.046295+00
aefa9ad7-bb9f-4df5-a947-cfe1a8bacd06	1	\N	村の少年タム_985	6	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:16.119502+00	2025-06-13 14:52:11.046295+00
ba4869ec-83bd-40cf-ac61-7a39b11f0d1b	2	\N	見習い狩人サラ_566	8	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:14:47.152746+00	2025-06-13 14:52:11.046295+00
bee9456e-085b-4876-8300-ad04b9d80d89	3	\N	魔法学校の生徒リオ_429	7	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:10.570874+00	2025-06-13 14:52:11.046295+00
d5448ee5-274c-42ad-b39c-2c5fdfb46223	3	\N	魔法学校の生徒リオ_896	7	34	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:12:15.393377+00	2025-06-13 14:52:11.046295+00
e40de087-03aa-48fd-8920-00509652d2e3	2	\N	見習い狩人サラ_171	6	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:14:47.152746+00	2025-06-13 14:52:11.046295+00
e74fc2a7-bd2f-481a-8100-a1ed8e58e325	2	\N	見習い狩人サラ_382	9	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:26.327632+00	2025-06-13 14:52:11.046295+00
fe379f0e-9af0-48e0-ba49-fc5a4845109d	3	\N	魔法学校の生徒リオ_296	8	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:27:47.180135+00	2025-06-13 14:52:11.046295+00
fe9b5df3-15d4-40f2-945d-24509ad9ee32	2	\N	見習い狩人サラ_79	6	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:16:47.157464+00	2025-06-13 14:52:11.046295+00
c200d548-c6c9-49fa-a882-a4a21b0fe8f3	2	\N	見習い狩人サラ_821	7	44	visiting	\N	2025-06-13 14:52:11.511626+00	2025-06-13 16:14:11.511626+00	f	\N	\N	2025-06-13 14:52:11.507496+00	2025-06-13 14:52:11.507496+00
f5ca47db-98c8-48f7-bb5c-f1ca469a4ce2	3	\N	魔法学校の生徒リオ_483	6	37	visiting	\N	2025-06-13 14:52:11.511626+00	2025-06-13 17:24:11.511626+00	f	\N	\N	2025-06-13 14:52:11.507496+00	2025-06-13 14:52:11.507496+00
14416038-43d7-4485-bf28-9ec0dc0d7b81	3	\N	魔法学校の生徒リオ_240	7	36	visiting	\N	2025-06-13 14:52:11.511626+00	2025-06-13 17:52:11.511626+00	f	\N	\N	2025-06-13 14:52:11.507496+00	2025-06-13 14:52:11.507496+00
a3ba4e80-f072-4c81-ba39-9d5d0014fd1d	2	\N	見習い狩人サラ_510	7	47	visiting	\N	2025-06-13 14:52:17.891031+00	2025-06-13 16:04:17.891031+00	f	\N	\N	2025-06-13 14:52:17.889381+00	2025-06-13 14:52:17.889381+00
164fd77e-2b7c-480a-ae1a-756815ad7213	2	\N	見習い狩人サラ_646	10	42	visiting	\N	2025-06-13 14:56:45.245354+00	2025-06-13 16:13:45.245354+00	f	\N	\N	2025-06-13 14:56:45.242081+00	2025-06-13 14:56:45.242081+00
a8c1d712-eb4f-4dd0-87eb-91648f1746d2	2	\N	見習い狩人サラ_487	9	10	visiting	\N	2025-06-13 14:56:45.245354+00	2025-06-13 16:34:45.245354+00	f	\N	\N	2025-06-13 14:56:45.242081+00	2025-06-13 14:56:45.242081+00
015ed509-fc4d-489c-8b62-2915280c74f7	2	\N	見習い狩人サラ_561	9	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:16.119502+00	2025-06-13 14:57:41.22328+00
e146543d-d13f-4a6a-88df-a99fc301ade7	2	\N	見習い狩人サラ_227	6	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:16:17.117066+00	2025-06-13 14:58:40.90499+00
2c7b7fcb-45fe-44b9-8270-7b5097cca983	3	\N	魔法学校の生徒リオ_857	6	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:22:16.160804+00	2025-06-13 14:59:41.243992+00
943220bf-7443-44eb-b88e-2d0081320d98	1	\N	村の少年タム_713	6	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:40.642037+00	2025-06-13 15:06:08.660403+00
77abb9f6-80f0-44bd-84dd-faa364ef991c	2	\N	見習い狩人サラ_52	10	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:52:21.366202+00	2025-06-13 15:06:38.642892+00
52847b81-4bbf-4c20-9642-6dfa4ce26cd7	2	\N	見習い狩人サラ_943	7	44	visiting	\N	2025-06-13 15:07:08.748471+00	2025-06-13 17:33:08.748471+00	f	\N	\N	2025-06-13 15:07:08.747228+00	2025-06-13 15:07:08.747228+00
0f597f4e-176c-4820-b98e-f57ba9622654	2	\N	見習い狩人サラ_823	9	39	visiting	\N	2025-06-13 15:08:18.295862+00	2025-06-13 17:57:18.295862+00	f	\N	\N	2025-06-13 15:08:18.29464+00	2025-06-13 15:08:18.29464+00
731106de-3537-484f-8326-d5c6ac0fdb0d	3	\N	魔法学校の生徒リオ_354	8	29	visiting	\N	2025-06-13 15:08:18.295862+00	2025-06-13 16:11:18.295862+00	f	\N	\N	2025-06-13 15:08:18.29464+00	2025-06-13 15:08:18.29464+00
cdb250ec-bed3-46a3-a4e5-395ce4ab9cdf	3	\N	魔法学校の生徒リオ_883	6	49	visiting	\N	2025-06-13 15:12:21.556589+00	2025-06-13 18:09:21.556589+00	f	\N	\N	2025-06-13 15:12:21.55577+00	2025-06-13 15:12:21.55577+00
cea9e029-329e-4696-b401-6770393003bc	2	\N	見習い狩人サラ_840	10	32	visiting	\N	2025-06-13 15:13:51.599024+00	2025-06-13 16:07:51.599024+00	f	\N	\N	2025-06-13 15:13:51.598084+00	2025-06-13 15:13:51.598084+00
7067a43d-44db-4a84-ae2e-72494cc96f7e	2	\N	見習い狩人サラ_673	6	9	visiting	\N	2025-06-13 15:13:51.599024+00	2025-06-13 15:59:51.599024+00	f	\N	\N	2025-06-13 15:13:51.598084+00	2025-06-13 15:13:51.598084+00
83636661-dc7d-496b-b756-9d89af09436a	2	\N	見習い狩人サラ_826	8	28	visiting	\N	2025-06-13 15:14:21.554248+00	2025-06-13 16:41:21.554248+00	f	\N	\N	2025-06-13 15:14:21.553374+00	2025-06-13 15:14:21.553374+00
eadcf2b1-e075-4846-bd79-c4965032c682	2	\N	見習い狩人サラ_945	9	0	visiting	\N	2025-06-13 15:14:21.554248+00	2025-06-13 16:24:21.554248+00	f	\N	\N	2025-06-13 15:14:21.553374+00	2025-06-13 15:14:21.553374+00
af70a838-c859-4c4b-8dd4-f7308fa14ffd	3	\N	魔法学校の生徒リオ_752	8	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:18:47.064375+00	2025-06-13 15:16:51.497143+00
91c53756-12f5-4966-90fe-d8b71b9568c0	2	\N	見習い狩人サラ_766	8	6	visiting	\N	2025-06-13 15:16:51.565029+00	2025-06-13 18:07:51.565029+00	f	\N	\N	2025-06-13 15:16:51.564004+00	2025-06-13 15:16:51.564004+00
6bd14f11-b9c3-4467-a40c-c5273e74b76b	3	\N	魔法学校の生徒リオ_942	5	7	visiting	\N	2025-06-13 15:18:04.112705+00	2025-06-13 18:02:04.112705+00	f	\N	\N	2025-06-13 15:18:04.110746+00	2025-06-13 15:18:04.110746+00
8ee25b2d-a247-4dfc-a096-f7b324c1115d	2	\N	見習い狩人サラ_489	9	44	visiting	\N	2025-06-13 15:18:04.112705+00	2025-06-13 16:56:04.112705+00	f	\N	\N	2025-06-13 15:18:04.110746+00	2025-06-13 15:18:04.110746+00
137a308b-e5f2-4b3a-8278-bf1698127f9b	1	\N	村の少年タム_694	5	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:40.642037+00	2025-06-13 15:26:03.85797+00
cc111a59-e37d-4821-a541-0684daffda1e	3	\N	魔法学校の生徒リオ_379	4	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:12:45.417177+00	2025-06-13 15:33:03.963355+00
06bab10c-90f6-4ae2-865b-dea9bc39ecd5	3	\N	魔法学校の生徒リオ_32	8	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:40.642037+00	2025-06-13 15:37:03.919623+00
7b2ddeb4-f5b1-4e22-9a9a-c8574063e500	3	\N	魔法学校の生徒リオ_211	5	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:19:17.021077+00	2025-06-13 15:42:33.922994+00
a82eef07-4ec8-4be8-9f3e-ce65decc0312	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_612	8	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:54.441897+00	2025-06-13 07:36:15.893861+00
62d2417d-ac9b-4091-bea3-e4b0086ddb1a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_859	9	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:00.26837+00	2025-06-13 07:43:24.317758+00
0367e575-a25e-4d8d-9d00-875a5a0882c8	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_835	5	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:26.916631+00	2025-06-13 07:46:22.197102+00
30d3f4d7-fc19-47dd-88e4-03e74eeeeaa4	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_289	4	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:30.198296+00	2025-06-13 05:51:53.946644+00
ec042231-a0cd-48a0-a913-6c7fcd450782	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_252	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:30.181117+00	2025-06-13 05:52:53.95802+00
1136f3f1-1e88-44d1-af18-163cc09bebb0	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_235	7	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:54.441897+00	2025-06-13 05:54:23.952023+00
057c315d-519f-4999-be3a-bae21e4478f8	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_31	5	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:26.916631+00	2025-06-13 05:54:54.645875+00
a11e3a7c-e832-446e-800a-c72d8244958a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_61	5	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:25.083778+00	2025-06-13 05:55:53.954864+00
5a6ccdd7-fc99-4621-ba4e-7faa4669ee34	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_58	6	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:00.263613+00	2025-06-13 06:04:43.120378+00
b6e411d0-f791-4974-947c-4cf0a98eb9e1	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_974	4	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:05:00.301456+00	2025-06-13 06:04:43.120378+00
b1c861c9-db74-4c72-867f-222d5d6b0790	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_419	5	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:30.198296+00	2025-06-13 06:07:42.953541+00
01b60648-c842-44c3-bdac-c1ec17aedd21	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_709	7	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:18.201764+00	2025-06-13 06:18:18.659768+00
8c344a58-98d1-4639-960d-b00a17d40561	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_852	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:03:00.234697+00	2025-06-13 06:18:18.659768+00
ae7c7254-6ca4-47dd-adc4-75385bda5762	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_900	10	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:30.181117+00	2025-06-13 06:19:48.929154+00
6b1c80a3-dd01-4045-9968-854f94814a54	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_743	5	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:00.26837+00	2025-06-13 06:20:18.666515+00
7cab8f83-856a-4811-8428-f8928c1770c0	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_735	10	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:00.26837+00	2025-06-13 06:22:18.6752+00
ab723116-d6a6-453b-995c-355a6fbb57fd	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_978	3	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:03:30.144763+00	2025-06-13 06:23:48.671035+00
89dc776b-37b7-4a2c-8d6d-e156616c6858	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_40	8	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:05:30.18382+00	2025-06-13 06:26:48.694835+00
ad524b1b-3292-4983-9987-b7f9684c5c6a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_577	4	34	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:30.189023+00	2025-06-13 06:26:48.694835+00
1d4b883d-ad76-4624-b05a-d86931f0f744	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_644	6	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:30.176389+00	2025-06-13 06:28:30.831901+00
8a4d27cb-9394-4632-9ccc-0e92f7395df9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_270	8	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:00.26837+00	2025-06-13 06:29:24.777832+00
0b34a32d-f19a-4813-93a6-6dcf1e30ffec	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_401	9	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:30.198296+00	2025-06-13 06:32:54.779117+00
f265d120-bb11-48ea-ad93-798ee911fee6	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_542	8	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:25.083778+00	2025-06-13 06:35:54.742557+00
9c22c3b9-9dd8-4cbb-98ae-390be6907426	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_608	7	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:05:30.18382+00	2025-06-13 06:36:54.768439+00
177685b0-ddb1-46ca-a059-56221e442601	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_445	4	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:03:00.234697+00	2025-06-13 06:42:46.82754+00
1de2e7d2-a4bd-4851-a786-585d70b0ad65	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_801	9	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:53.161042+00	2025-06-13 06:42:46.82754+00
a97a5f08-9a38-40ed-af5c-162658da0c20	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_174	4	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:30.181117+00	2025-06-13 06:43:31.166025+00
1aa25888-8b29-4963-8e8a-fb38450ce593	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_348	10	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:00:30.176389+00	2025-06-13 07:13:13.236721+00
2b861e39-fb5e-419a-a77d-9129d83abd5c	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_62	6	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:18.201764+00	2025-06-13 07:13:13.236721+00
2e2889f9-c7db-4d5e-bd97-d3a632be4fd0	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_665	6	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:54.441897+00	2025-06-13 07:13:13.236721+00
99b4f287-a530-4bba-a290-cdba9d3e9cde	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_888	7	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:25.083778+00	2025-06-13 07:13:13.236721+00
9d068301-4576-4e29-bec4-d60318f6c392	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_855	4	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:18.201764+00	2025-06-13 07:13:13.236721+00
9820a4a0-bfe9-4604-a2fc-0353787b223c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_625	8	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:24.332606+00	2025-06-13 07:17:42.133454+00
247fd06e-0d22-4e64-ab43-468b211fd118	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_740	7	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:54.441897+00	2025-06-13 07:20:02.843082+00
a62ee508-ef78-4829-b011-b72c2aaf72be	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_954	7	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:00.263613+00	2025-06-13 07:30:03.648661+00
cebff189-3afe-4e91-9cca-03b7487aa824	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_61	8	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:05:00.301456+00	2025-06-13 07:32:03.704992+00
ed16603e-1681-4075-bf18-8587176db69d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_108	10	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:31.121091+00	2025-06-13 07:34:45.995119+00
67e06bb2-9d75-4a1b-9c86-3da2991f946b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_302	4	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:00.263613+00	2025-06-13 07:47:22.151615+00
0290f90b-2528-4233-96b7-b66d2d721db9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_983	6	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:31.121091+00	2025-06-13 07:47:52.172178+00
3c7754ec-958d-4174-9de5-bdcd01662660	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_827	5	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:26.916631+00	2025-06-13 07:48:52.148245+00
5ac153fc-5d77-44d4-8bd0-c29a16ce0e2c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_961	10	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:25.083778+00	2025-06-13 07:50:52.213183+00
b0fa40b6-db18-4818-b709-2f8cb5923fe5	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_301	4	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:30.181117+00	2025-06-13 07:51:52.158531+00
7572f28a-f4be-453c-a89a-efb188968924	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_244	8	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:03:30.144763+00	2025-06-13 07:54:52.169341+00
2ccf1e82-7772-4fd9-9566-4752d52a835e	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_92	7	31	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:04:00.263613+00	2025-06-13 07:55:22.163582+00
f6029198-1e35-465f-af2a-2bb9096b366d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_644	4	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:53.161042+00	2025-06-13 08:01:22.20231+00
21277967-bef5-4528-9393-4f0ec9f26200	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_528	6	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:25.083778+00	2025-06-13 08:01:52.285088+00
46c651bb-5143-4faa-a969-90681163a285	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_153	4	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:53.161042+00	2025-06-13 08:02:22.209839+00
5585b615-d41a-4b91-97f9-ad4a55145cfa	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_226	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:06:54.441897+00	2025-06-13 08:04:22.209539+00
2856d311-567a-4752-b818-224bccaaddb1	2	\N	見習い狩人サラ_155	10	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:15.41926+00	2025-06-13 14:52:11.046295+00
f3e9f530-50ac-40c5-bd1c-c8899ca3f1de	1	\N	村の少年タム_623	3	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:15.41926+00	2025-06-13 14:54:41.399466+00
ea9ccbc1-a59c-4e16-a149-3838066d9dba	2	\N	見習い狩人サラ_557	8	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:10.580255+00	2025-06-13 15:15:21.477778+00
eaa016ba-aff1-43b4-92dc-018c55af3475	3	\N	魔法学校の生徒リオ_424	7	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:10.580255+00	2025-06-13 15:18:33.930279+00
b94e9825-ce21-403d-a350-f959d5aec586	3	\N	魔法学校の生徒リオ_324	8	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:14:17.160295+00	2025-06-13 15:33:34.199717+00
41d377ee-0199-4cca-89d3-062c50cf6d98	2	\N	見習い狩人サラ_746	10	28	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:40.577422+00	2025-06-13 15:42:04.094227+00
0c09f139-6284-4b62-97fc-583fd24ae598	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_942	5	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:44.165117+00	2025-06-13 06:31:54.723361+00
fe80cf2e-71cb-4292-80f9-4307272deb8d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_947	7	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:44.165117+00	2025-06-13 07:53:52.184146+00
ee180145-d226-4a8c-90f3-662d0131c95e	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_252	6	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:44.165117+00	2025-06-13 08:01:52.285088+00
1b802c09-2601-47ee-b475-97f08faa2c80	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_532	3	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:44.165117+00	2025-06-13 08:05:52.202052+00
960e5f56-9155-437f-8e87-ee256a601431	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_661	6	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:44.165117+00	2025-06-13 08:07:52.180749+00
7fedb2ed-af55-41e3-9a85-e593debeebaa	3	\N	魔法学校の生徒リオ_539	5	29	visiting	\N	2025-06-13 13:21:47.116187+00	2025-06-13 16:06:47.116187+00	f	\N	\N	2025-06-13 13:21:47.114875+00	2025-06-13 13:21:47.114875+00
0d7e7a34-950a-4e5c-8985-078aa2343dde	2	\N	見習い狩人サラ_525	6	1	visiting	\N	2025-06-13 13:22:47.086162+00	2025-06-13 16:19:47.086162+00	f	\N	\N	2025-06-13 13:22:47.085046+00	2025-06-13 13:22:47.085046+00
e53ad94d-eef4-4585-b0d8-8927a371b2f0	3	\N	魔法学校の生徒リオ_561	7	10	visiting	\N	2025-06-13 13:31:23.004608+00	2025-06-13 16:00:23.004608+00	f	\N	\N	2025-06-13 13:31:23.003352+00	2025-06-13 13:31:23.003352+00
46511a27-797d-477c-abac-8182a161cb17	1	\N	村の少年タム_161	7	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:40.610782+00	2025-06-13 13:43:06.579021+00
66bfdcdb-32cf-453c-b40e-894aa55b2517	2	\N	見習い狩人サラ_608	9	38	visiting	\N	2025-06-13 13:47:59.657637+00	2025-06-13 16:23:59.657637+00	f	\N	\N	2025-06-13 13:47:59.656519+00	2025-06-13 13:47:59.656519+00
b77bdaa1-766f-4c86-8dad-5e36ba256e21	2	\N	見習い狩人サラ_769	7	50	visiting	\N	2025-06-13 13:47:59.657637+00	2025-06-13 16:36:59.657637+00	f	\N	\N	2025-06-13 13:47:59.656519+00	2025-06-13 13:47:59.656519+00
431fa3bd-017a-407b-bac7-cd7c749236f1	1	\N	村の少年タム_102	3	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:48.446398+00	2025-06-13 13:49:51.277555+00
05505e0c-05b7-45ed-86fd-fbbe2698ece5	1	\N	村の少年タム_369	7	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:15.818257+00	2025-06-13 14:52:11.046295+00
0a069536-fe31-436e-b275-9f1bf7b7883f	2	\N	見習い狩人サラ_745	9	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:46:11.2618+00	2025-06-13 14:52:11.046295+00
14749dc3-dd71-483e-9216-4adf8b747cff	3	\N	魔法学校の生徒リオ_723	8	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:57.880026+00	2025-06-13 14:52:11.046295+00
15844451-93cf-4dfb-aa20-2e316576b565	1	\N	村の少年タム_238	6	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:40.629673+00	2025-06-13 14:52:11.046295+00
1f350145-a38d-4560-9602-79de4ef8fdaa	3	\N	魔法学校の生徒リオ_842	8	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:47.271588+00	2025-06-13 14:52:11.046295+00
2ed3b47e-8955-4d21-b1fc-4e527229f361	2	\N	見習い狩人サラ_264	6	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:10.553962+00	2025-06-13 14:52:11.046295+00
3199ddcb-6803-4dd6-a7db-241c5e24eb91	3	\N	魔法学校の生徒リオ_347	6	1	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:29:46.184701+00	2025-06-13 14:52:11.046295+00
347d1bac-dd78-4ad0-8b84-07b49c71a940	2	\N	見習い狩人サラ_125	7	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:55:45.461435+00	2025-06-13 14:52:11.046295+00
35f7548a-0ed7-4b16-b80d-ead60ae42e27	1	\N	村の少年タム_586	4	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:58:16.049353+00	2025-06-13 14:52:11.046295+00
365522da-8783-4299-95fe-c9b1ec5b1da1	2	\N	見習い狩人サラ_918	6	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:57.880026+00	2025-06-13 14:52:11.046295+00
380fc4dc-a009-4bc5-abb3-8b3e5a723589	2	\N	見習い狩人サラ_524	7	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:17:17.111303+00	2025-06-13 14:52:11.046295+00
62ed7d8e-a26c-4656-a6e3-11ffe56150a0	2	\N	見習い狩人サラ_713	9	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:59:15.818257+00	2025-06-13 14:52:11.046295+00
679de23c-c9e2-4670-9f58-1c34787c0c26	2	\N	見習い狩人サラ_202	8	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:33:37.868265+00	2025-06-13 14:52:11.046295+00
72f96a09-a4dc-40d3-8489-4257ef9d6bb0	3	\N	魔法学校の生徒リオ_611	7	2	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:40.577422+00	2025-06-13 14:52:11.046295+00
74231a45-2ba0-402b-a51c-7ad4bf227a4b	3	\N	魔法学校の生徒リオ_190	6	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:14:17.160295+00	2025-06-13 14:52:11.046295+00
75951204-488d-48c9-bb54-60214366a099	1	\N	村の少年タム_604	7	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:04.330882+00	2025-06-13 14:52:11.046295+00
801fcbb9-10f4-4e8f-a8f2-e0bbf7f7e66f	3	\N	魔法学校の生徒リオ_839	8	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:13:15.460044+00	2025-06-13 14:52:11.046295+00
825f189d-642b-4620-99b2-6fb5d2c90a86	2	\N	見習い狩人サラ_64	9	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:17.225668+00	2025-06-13 14:52:11.046295+00
86e6b096-eea9-410c-849f-1cee81f66fde	1	\N	村の少年タム_962	6	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:58:16.049353+00	2025-06-13 14:52:11.046295+00
89b734bb-0495-4c8d-b065-e2e10523b288	3	\N	魔法学校の生徒リオ_762	6	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:17.166584+00	2025-06-13 14:52:11.046295+00
90e5785f-d0c1-468e-9ca5-b8eaf16662d7	1	\N	村の少年タム_376	7	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:04.330882+00	2025-06-13 14:52:11.046295+00
914d5eda-32e1-4fd9-acc7-17b45257390c	2	\N	見習い狩人サラ_825	6	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:17.166584+00	2025-06-13 14:52:11.046295+00
9afa6aec-e0c6-4968-b302-bb63e0fc2841	1	\N	村の少年タム_68	7	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:06:15.408403+00	2025-06-13 14:52:11.046295+00
a2c4711a-9324-42e9-932a-6bfc3734ca3f	3	\N	魔法学校の生徒リオ_229	5	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:21:17.156043+00	2025-06-13 14:52:11.046295+00
a647b589-4f8e-4cf2-8132-faa6a699b8ec	2	\N	見習い狩人サラ_417	9	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:11:32.547294+00	2025-06-13 14:52:11.046295+00
b0636653-af84-4544-aee5-dde8e628cb89	2	\N	見習い狩人サラ_294	8	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:21:17.156043+00	2025-06-13 14:52:11.046295+00
b383332f-b561-42a5-9d93-9d4ebe5d3b49	3	\N	魔法学校の生徒リオ_407	4	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:18:17.005603+00	2025-06-13 14:52:11.046295+00
b8359bf3-87b4-4c5e-917b-eafb733a4a05	3	\N	魔法学校の生徒リオ_800	4	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:12:19.578878+00	2025-06-13 14:52:11.046295+00
d3f91e2e-4ffc-40e8-9d30-02ddaadae37b	2	\N	見習い狩人サラ_351	10	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:48.446398+00	2025-06-13 14:52:11.046295+00
df48a735-b958-428e-8ebf-43f702732180	3	\N	魔法学校の生徒リオ_129	4	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:40.610782+00	2025-06-13 14:52:11.046295+00
51a71a56-c7d0-48c8-b285-7ea35bf73f78	2	\N	見習い狩人サラ_909	9	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:21:47.114875+00	2025-06-13 14:59:41.243992+00
587de9e8-934d-4dac-aae2-7156379205d8	1	\N	村の少年タム_668	6	27	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:48.446398+00	2025-06-13 14:59:41.243992+00
8e3e67be-8b3f-4a99-8a6c-4c020f7d9ff5	2	\N	見習い狩人サラ_62	6	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:29:46.184701+00	2025-06-13 15:02:10.938142+00
eb058689-05e7-42ae-8229-3b742090661e	3	\N	魔法学校の生徒リオ_338	8	24	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:57.880026+00	2025-06-13 15:07:08.661251+00
1d6eb81d-d256-4891-b8cc-93d4208e9256	3	\N	魔法学校の生徒リオ_764	7	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:22:17.123847+00	2025-06-13 15:11:21.474485+00
9638aeed-851d-4d19-9f9b-d2a83f4008c0	3	\N	魔法学校の生徒リオ_938	5	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:44.184436+00	2025-06-13 15:11:51.520475+00
bfd38e52-535c-4e1e-b4b9-b30253abad6f	3	\N	魔法学校の生徒リオ_329	7	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:47:59.656519+00	2025-06-13 15:25:03.916502+00
e157b69f-da65-4b40-860e-a04cc32170c9	2	\N	見習い狩人サラ_751	9	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:50:40.386042+00	2025-06-13 15:26:03.85797+00
f73291ee-a5f5-4785-a4df-3b7bbf355ad6	2	\N	見習い狩人サラ_151	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:48:44.184436+00	2025-06-13 15:31:03.884879+00
954bf019-48c7-4ad9-906c-05b13adabc5e	2	\N	見習い狩人サラ_923	9	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:21:47.114875+00	2025-06-13 15:33:03.963355+00
0cf91860-2db3-4523-b2db-e30508c9b2d7	3	\N	魔法学校の生徒リオ_962	8	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:29:46.184701+00	2025-06-13 15:34:03.893434+00
7eb0571f-a928-432b-ab08-f3fc6d482a9d	3	\N	魔法学校の生徒リオ_818	8	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:17:47.120869+00	2025-06-13 15:42:04.094227+00
190513b7-990b-4ba4-b901-9d90a72e48e3	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_427	10	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:24.33886+00	2025-06-13 06:30:24.739499+00
86c9fcf8-fc34-4545-9ebd-416405b9b6f0	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_452	7	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:54.365278+00	2025-06-13 06:42:46.82754+00
03113887-a403-4b55-8ca2-d16cecccc7ef	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_488	9	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:24.33886+00	2025-06-13 07:13:13.236721+00
719e9338-d622-488f-bc6f-7d41c57a330c	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_377	7	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:54.365278+00	2025-06-13 07:13:13.236721+00
7466b808-bf80-4be6-b142-4096ac5682e1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_560	6	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:54.365278+00	2025-06-13 07:13:13.236721+00
3f116bd9-57f7-4ac9-abf7-bcb37b71910a	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_557	4	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:54.365278+00	2025-06-13 07:14:03.065366+00
d1087931-9650-4bbe-b23b-e8458bca49c9	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_265	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:54.365278+00	2025-06-13 07:14:03.065366+00
04a4a2d0-b68f-45dd-9c3a-8a9162299df0	2	\N	見習い狩人サラ_260	8	43	visiting	\N	2025-06-13 13:31:52.993621+00	2025-06-13 16:15:52.993621+00	f	\N	\N	2025-06-13 13:31:52.992413+00	2025-06-13 13:31:52.992413+00
e440c2f7-4ce0-40b9-97ad-ab69cc487634	2	\N	見習い狩人サラ_960	9	21	visiting	\N	2025-06-13 13:31:52.993621+00	2025-06-13 16:12:52.993621+00	f	\N	\N	2025-06-13 13:31:52.992413+00	2025-06-13 13:31:52.992413+00
0de32543-11ad-4303-a545-40cd38f9c5f9	3	\N	魔法学校の生徒リオ_367	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:09.237548+00	2025-06-13 13:48:09.444313+00
b2c14248-390b-421b-9e30-0a7b43855699	2	\N	見習い狩人サラ_742	7	8	visiting	\N	2025-06-13 13:48:09.668892+00	2025-06-13 16:26:09.668892+00	f	\N	\N	2025-06-13 13:48:09.667971+00	2025-06-13 13:48:09.667971+00
9449de98-1b2e-4d41-b15d-98d8c4c7b36f	2	\N	見習い狩人サラ_818	8	4	visiting	\N	2025-06-13 13:48:09.668892+00	2025-06-13 15:56:09.668892+00	f	\N	\N	2025-06-13 13:48:09.667971+00	2025-06-13 13:48:09.667971+00
4f4b70ca-456e-484a-aa09-4c08b9eba7d6	1	\N	村の少年タム_7	5	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:11.065238+00	2025-06-13 14:52:11.046295+00
662ee057-1179-4db0-99ee-91622c56c1f5	3	\N	魔法学校の生徒リオ_97	7	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:11.065238+00	2025-06-13 14:52:11.046295+00
b8ae6145-b456-4f4a-8d17-9e9a1a1398c1	2	\N	見習い狩人サラ_518	8	29	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:49:33.241344+00	2025-06-13 14:52:11.046295+00
b951f778-deae-45c2-b75e-921849cc94e6	3	\N	魔法学校の生徒リオ_983	7	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:22:51.213332+00	2025-06-13 14:52:11.046295+00
b954792a-3298-4d7f-9f43-d13865944c03	2	\N	見習い狩人サラ_5	8	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:19:47.064587+00	2025-06-13 14:52:11.046295+00
be847ac7-127b-4540-842f-ee859e4a81ce	3	\N	魔法学校の生徒リオ_870	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:45.409626+00	2025-06-13 14:52:11.046295+00
c3bb400a-1531-4204-82be-10f01b5452ba	2	\N	見習い狩人サラ_884	9	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:37.502269+00	2025-06-13 14:52:11.046295+00
ccbeb08e-615b-42ad-ab3c-a73b9118bc31	3	\N	魔法学校の生徒リオ_366	5	4	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:40.283532+00	2025-06-13 14:52:11.046295+00
cd44e9cc-a7c4-40a7-be45-b8fe1d60994a	1	\N	村の少年タム_51	3	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:47:11.097182+00	2025-06-13 14:52:11.046295+00
d09f9203-4fe1-4d6f-b94f-8fb8de50304f	2	\N	見習い狩人サラ_524	7	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:17.166584+00	2025-06-13 14:52:11.046295+00
d18555fe-7091-45ae-90a4-63591e869d0c	3	\N	魔法学校の生徒リオ_877	7	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:56:45.404495+00	2025-06-13 14:52:11.046295+00
d354cbba-c5b7-42a8-910f-6d79fedd64e9	1	\N	村の少年タム_376	4	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:07:15.438851+00	2025-06-13 14:52:11.046295+00
d429e28f-00dd-401e-833e-5ed70e234436	2	\N	見習い狩人サラ_344	7	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:11:45.410138+00	2025-06-13 14:52:11.046295+00
d77bf6c8-ae6d-44dd-b8aa-51b8a9854fb4	1	\N	村の少年タム_716	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:51:40.629673+00	2025-06-13 14:52:11.046295+00
d8f50817-557f-419f-b660-5a51ece2879d	2	\N	見習い狩人サラ_391	10	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:27:17.177829+00	2025-06-13 14:52:11.046295+00
e6009b98-f5ac-458d-81e3-05b06c8af731	3	\N	魔法学校の生徒リオ_107	5	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:05:15.395612+00	2025-06-13 14:52:11.046295+00
e7b09c99-253c-4e43-9537-e9044c1a3a62	2	\N	見習い狩人サラ_388	6	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:17:17.111303+00	2025-06-13 14:52:11.046295+00
e834a8bd-9d74-4dad-ab08-84dbc8f3a5bd	2	\N	見習い狩人サラ_80	10	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:15:47.112554+00	2025-06-13 14:52:11.046295+00
e8ce8661-98ee-4d69-bc65-c80ef4a1c79c	1	\N	村の少年タム_833	4	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:04:45.424176+00	2025-06-13 14:52:11.046295+00
ec76028b-c388-427a-a470-634d1589d73b	1	\N	村の少年タム_905	4	12	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:09:15.409633+00	2025-06-13 14:52:11.046295+00
ee2fb295-af45-40ab-940a-b22df890021b	1	\N	村の少年タム_100	3	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:10:37.502269+00	2025-06-13 14:52:11.046295+00
efa1dd0e-2df5-4aeb-a9ed-387dd573aa81	3	\N	魔法学校の生徒リオ_654	8	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:09:45.465851+00	2025-06-13 14:52:11.046295+00
efb0c2ab-3b52-419f-81dc-bc06c7cf9431	2	\N	見習い狩人サラ_916	6	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:20:17.005158+00	2025-06-13 14:52:11.046295+00
f5227e24-8c50-4124-9d9a-f91a8159b3a3	3	\N	魔法学校の生徒リオ_88	7	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:25:17.323931+00	2025-06-13 14:52:11.046295+00
f84be4ae-d201-48bd-b1c0-e795ac710e00	1	\N	村の少年タム_121	3	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:00:15.41926+00	2025-06-13 14:52:11.046295+00
ff14fcae-f89f-4a8b-84a7-00ff830c143c	3	\N	魔法学校の生徒リオ_72	5	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:37:27.740509+00	2025-06-13 14:52:11.046295+00
37b0fbb5-1967-4d60-8a3b-cdc246358d99	2	\N	見習い狩人サラ_210	9	23	visiting	\N	2025-06-13 14:52:41.015536+00	2025-06-13 17:40:41.015536+00	f	\N	\N	2025-06-13 14:52:41.014487+00	2025-06-13 14:52:41.014487+00
284018d8-7879-4421-9b21-9bb077e861dd	3	\N	魔法学校の生徒リオ_297	8	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:01:15.665742+00	2025-06-13 14:53:40.958658+00
295611ed-5297-4906-bf2b-969ad66b0033	2	\N	見習い狩人サラ_926	6	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:22:51.213332+00	2025-06-13 14:55:10.915971+00
c2c68564-9951-4b61-96b1-6df30530d8d3	3	\N	魔法学校の生徒リオ_932	5	22	visiting	\N	2025-06-13 14:57:11.167617+00	2025-06-13 16:28:11.167617+00	f	\N	\N	2025-06-13 14:57:11.166491+00	2025-06-13 14:57:11.166491+00
58cfdde6-8b34-41be-a54e-6f80116dba8b	3	\N	魔法学校の生徒リオ_868	4	43	visiting	\N	2025-06-13 14:57:11.167617+00	2025-06-13 17:56:11.167617+00	f	\N	\N	2025-06-13 14:57:11.166491+00	2025-06-13 14:57:11.166491+00
7d002dd6-6629-42e3-a4d0-2f0ab0ee0f7a	2	\N	見習い狩人サラ_576	9	17	visiting	\N	2025-06-13 15:07:21.458419+00	2025-06-13 18:02:21.458419+00	f	\N	\N	2025-06-13 15:07:21.456221+00	2025-06-13 15:07:21.456221+00
5d2da451-1f47-41e1-8f86-bf439c7bc929	2	\N	見習い狩人サラ_358	10	2	visiting	\N	2025-06-13 15:07:21.458419+00	2025-06-13 16:22:21.458419+00	f	\N	\N	2025-06-13 15:07:21.456221+00	2025-06-13 15:07:21.456221+00
e2071218-b420-48b2-b8df-1d3fa48b7fb6	2	\N	見習い狩人サラ_111	8	34	visiting	\N	2025-06-13 15:07:51.461166+00	2025-06-13 16:41:51.461166+00	f	\N	\N	2025-06-13 15:07:51.460245+00	2025-06-13 15:07:51.460245+00
c5b6ba45-1674-4a90-bcd9-5cae4a53251e	3	\N	魔法学校の生徒リオ_435	8	31	visiting	\N	2025-06-13 15:07:51.461166+00	2025-06-13 16:19:51.461166+00	f	\N	\N	2025-06-13 15:07:51.460245+00	2025-06-13 15:07:51.460245+00
2c1b541a-d46c-4fb8-8396-2209a754e36a	3	\N	魔法学校の生徒リオ_128	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:30:16.00358+00	2025-06-13 15:17:33.896846+00
2d4d612e-6f98-45fc-8a30-627e1ede542a	3	\N	魔法学校の生徒リオ_803	8	48	visiting	\N	2025-06-13 15:18:04.112705+00	2025-06-13 16:38:04.112705+00	f	\N	\N	2025-06-13 15:18:04.110746+00	2025-06-13 15:18:04.110746+00
c87a4d44-07c8-4cb0-ae3a-412aba30a941	2	\N	見習い狩人サラ_998	9	30	visiting	\N	2025-06-13 15:19:03.976152+00	2025-06-13 17:11:03.976152+00	f	\N	\N	2025-06-13 15:19:03.974895+00	2025-06-13 15:19:03.974895+00
dd4dbe6a-1fc9-4768-81c2-9b7e3fb70e15	2	\N	見習い狩人サラ_4	9	6	visiting	\N	2025-06-13 15:19:33.993555+00	2025-06-13 17:40:33.993555+00	f	\N	\N	2025-06-13 15:19:33.992411+00	2025-06-13 15:19:33.992411+00
195b0c06-3f63-4921-a5ca-e2943877788b	3	\N	魔法学校の生徒リオ_633	5	10	visiting	\N	2025-06-13 15:19:33.993555+00	2025-06-13 16:04:33.993555+00	f	\N	\N	2025-06-13 15:19:33.992411+00	2025-06-13 15:19:33.992411+00
06d26c3a-96d5-42da-80fc-15a058ba7602	2	\N	見習い狩人サラ_855	9	20	visiting	\N	2025-06-13 15:19:33.993555+00	2025-06-13 18:06:33.993555+00	f	\N	\N	2025-06-13 15:19:33.992411+00	2025-06-13 15:19:33.992411+00
b8e72ffe-171d-4212-80b4-5d1e0124d76c	3	\N	魔法学校の生徒リオ_330	6	48	visiting	\N	2025-06-13 15:20:03.974483+00	2025-06-13 17:09:03.974483+00	f	\N	\N	2025-06-13 15:20:03.973328+00	2025-06-13 15:20:03.973328+00
2769cac9-7b48-4918-952d-3f2d7525fd67	2	\N	見習い狩人サラ_193	8	31	visiting	\N	2025-06-13 15:20:03.974483+00	2025-06-13 17:28:03.974483+00	f	\N	\N	2025-06-13 15:20:03.973328+00	2025-06-13 15:20:03.973328+00
9841a412-1615-4c66-9c06-8a5210206ddb	3	\N	魔法学校の生徒リオ_773	4	49	visiting	\N	2025-06-13 15:20:03.974483+00	2025-06-13 16:29:03.974483+00	f	\N	\N	2025-06-13 15:20:03.973328+00	2025-06-13 15:20:03.973328+00
aef02420-16e0-47ee-a8d4-2570fe3a8195	2	\N	見習い狩人サラ_580	6	16	visiting	\N	2025-06-13 15:21:28.883092+00	2025-06-13 17:15:28.883092+00	f	\N	\N	2025-06-13 15:21:28.881773+00	2025-06-13 15:21:28.881773+00
b8a8a32d-5622-4f28-b6fb-85cc13c7ec20	2	\N	見習い狩人サラ_294	6	8	visiting	\N	2025-06-13 15:21:28.883092+00	2025-06-13 16:51:28.883092+00	f	\N	\N	2025-06-13 15:21:28.881773+00	2025-06-13 15:21:28.881773+00
ff433774-aa68-40fd-b76f-ef438b6b874f	3	\N	魔法学校の生徒リオ_13	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:48:09.667971+00	2025-06-13 15:39:33.940158+00
aa6b6f3c-1746-4215-84cd-ad14f81fee06	3	\N	魔法学校の生徒リオ_494	5	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:57:11.166491+00	2025-06-13 15:45:33.947588+00
f9505cd6-70b3-4315-a526-dea0c8cc5c57	2	\N	見習い狩人サラ_263	10	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:30:16.00358+00	2025-06-13 15:46:34.037197+00
573bc898-28a0-46e4-8e3d-451241b0a595	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_232	4	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:54.359833+00	2025-06-13 06:42:46.82754+00
9bdec817-b7b7-4c80-b2cd-fd06213835ae	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_335	6	20	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:31.22088+00	2025-06-13 07:13:13.236721+00
cb8eb2b0-130e-4e85-8e0a-4180614938c1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_543	3	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:54.359833+00	2025-06-13 07:13:13.236721+00
60b13aa2-03ef-4ca5-befe-64f2a6ab5de5	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_938	6	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:54.359833+00	2025-06-13 07:39:15.915335+00
668d991e-4223-49bd-8604-5aa6e8fb3259	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_109	6	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:31.22088+00	2025-06-13 07:40:54.338983+00
6f46ab9c-6492-4fcc-8465-8f6b02ad5147	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_175	6	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:54.359833+00	2025-06-13 07:54:22.220004+00
9310301c-a71c-4d61-9644-8e0d967f9bfd	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_971	10	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:08:54.359833+00	2025-06-13 08:03:22.214815+00
9378d2c9-4c40-4601-b191-367ab7ce96ae	2	\N	見習い狩人サラ_154	7	36	visiting	\N	2025-06-13 13:33:50.620123+00	2025-06-13 16:16:50.620123+00	f	\N	\N	2025-06-13 13:33:50.61814+00	2025-06-13 13:33:50.61814+00
e0ccadd6-7552-49fc-9171-786c45383bce	2	\N	見習い狩人サラ_351	10	20	visiting	\N	2025-06-13 13:33:50.620123+00	2025-06-13 15:47:50.620123+00	f	\N	\N	2025-06-13 13:33:50.61814+00	2025-06-13 13:33:50.61814+00
ca20f35f-30ee-4847-8996-b04f93420a7f	1	\N	村の少年タム_356	5	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:15.359465+00	2025-06-13 13:46:36.438661+00
754de84c-dafb-429c-ab54-53120b47ddce	2	\N	見習い狩人サラ_965	9	12	visiting	\N	2025-06-13 13:48:26.523696+00	2025-06-13 16:28:26.523696+00	f	\N	\N	2025-06-13 13:48:26.522181+00	2025-06-13 13:48:26.522181+00
9a25652b-4f68-4f50-a6af-58b3cb1c267a	3	\N	魔法学校の生徒リオ_569	5	11	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:33:50.61814+00	2025-06-13 14:52:11.046295+00
c9b17e51-5e40-47eb-a236-ed49be927d33	1	\N	村の少年タム_896	5	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:01:45.477209+00	2025-06-13 14:52:11.046295+00
fb5828f1-98b3-4d1a-9225-724f8f658038	2	\N	見習い狩人サラ_551	10	26	visiting	\N	2025-06-13 14:53:11.005567+00	2025-06-13 17:20:11.005567+00	f	\N	\N	2025-06-13 14:53:11.003486+00	2025-06-13 14:53:11.003486+00
d7f2ba36-4e5e-42ba-b9d7-dde01e59f8b7	2	\N	見習い狩人サラ_128	10	42	visiting	\N	2025-06-13 14:53:11.005567+00	2025-06-13 17:12:11.005567+00	f	\N	\N	2025-06-13 14:53:11.003486+00	2025-06-13 14:53:11.003486+00
8945b14f-7290-48d7-8a31-a425c02e268e	2	\N	見習い狩人サラ_815	8	22	visiting	\N	2025-06-13 14:53:11.005567+00	2025-06-13 16:47:11.005567+00	f	\N	\N	2025-06-13 14:53:11.003486+00	2025-06-13 14:53:11.003486+00
d937e3ad-b651-42a3-8f66-3b0f89830a40	2	\N	見習い狩人サラ_504	8	45	visiting	\N	2025-06-13 14:55:02.994263+00	2025-06-13 16:53:02.994263+00	f	\N	\N	2025-06-13 14:55:02.992851+00	2025-06-13 14:55:02.992851+00
a573bcc4-be05-4323-8641-febc18b00c69	3	\N	魔法学校の生徒リオ_688	6	7	visiting	\N	2025-06-13 14:57:41.366403+00	2025-06-13 17:00:41.366403+00	f	\N	\N	2025-06-13 14:57:41.365407+00	2025-06-13 14:57:41.365407+00
f248d0c1-8f6e-4948-8f04-3edd1a0fb3ff	3	\N	魔法学校の生徒リオ_895	4	8	visiting	\N	2025-06-13 14:58:11.066405+00	2025-06-13 16:02:11.066405+00	f	\N	\N	2025-06-13 14:58:11.065207+00	2025-06-13 14:58:11.065207+00
0be44b63-4a32-43a7-b468-7a2fa752e239	2	\N	見習い狩人サラ_771	6	19	visiting	\N	2025-06-13 14:58:11.066405+00	2025-06-13 17:11:11.066405+00	f	\N	\N	2025-06-13 14:58:11.065207+00	2025-06-13 14:58:11.065207+00
757d9eab-ffbf-42ad-8adc-76e67c3d2992	3	\N	魔法学校の生徒リオ_333	5	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:01:45.477209+00	2025-06-13 15:04:31.785898+00
c3fc7135-3fe3-43a5-b54f-fef7b1853ace	2	\N	見習い狩人サラ_496	9	47	visiting	\N	2025-06-13 15:08:51.460052+00	2025-06-13 18:00:51.460052+00	f	\N	\N	2025-06-13 15:08:51.458931+00	2025-06-13 15:08:51.458931+00
bb614c73-0cc3-4354-856d-94ace94000c7	2	\N	見習い狩人サラ_201	9	31	visiting	\N	2025-06-13 15:09:52.418036+00	2025-06-13 16:22:52.418036+00	f	\N	\N	2025-06-13 15:09:52.416593+00	2025-06-13 15:09:52.416593+00
c5569ad3-d403-487e-b2e2-21bc68746ba9	3	\N	魔法学校の生徒リオ_750	7	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:32:44.807622+00	2025-06-13 15:10:51.377575+00
cdf0b605-ff60-4b15-aace-914cc192b5f0	2	\N	見習い狩人サラ_167	10	3	visiting	\N	2025-06-13 15:10:51.444421+00	2025-06-13 16:43:51.444421+00	f	\N	\N	2025-06-13 15:10:51.443548+00	2025-06-13 15:10:51.443548+00
6eb87d89-4e52-41e9-ad09-972b3ef0a20f	2	\N	見習い狩人サラ_860	7	1	visiting	\N	2025-06-13 15:10:51.444421+00	2025-06-13 17:19:51.444421+00	f	\N	\N	2025-06-13 15:10:51.443548+00	2025-06-13 15:10:51.443548+00
10759c3c-7302-41d0-956c-c05deba3a807	2	\N	見習い狩人サラ_825	7	21	visiting	\N	2025-06-13 15:11:21.543944+00	2025-06-13 17:11:21.543944+00	f	\N	\N	2025-06-13 15:11:21.543041+00	2025-06-13 15:11:21.543041+00
2b1b57df-854c-4ab9-a3ce-721cf7bd4428	2	\N	見習い狩人サラ_827	8	24	visiting	\N	2025-06-13 15:11:21.543944+00	2025-06-13 17:44:21.543944+00	f	\N	\N	2025-06-13 15:11:21.543041+00	2025-06-13 15:11:21.543041+00
cfea3ae0-bdee-4b84-bcb1-07234f56b8e0	3	\N	魔法学校の生徒リオ_499	4	31	visiting	\N	2025-06-13 15:11:21.543944+00	2025-06-13 17:25:21.543944+00	f	\N	\N	2025-06-13 15:11:21.543041+00	2025-06-13 15:11:21.543041+00
be8853dc-9921-496d-a8fa-ada6041f6762	2	\N	見習い狩人サラ_910	6	17	visiting	\N	2025-06-13 15:11:51.620331+00	2025-06-13 17:48:51.620331+00	f	\N	\N	2025-06-13 15:11:51.61936+00	2025-06-13 15:11:51.61936+00
c28c954b-9f5f-4261-bedd-2d4eb5744722	3	\N	魔法学校の生徒リオ_426	8	40	visiting	\N	2025-06-13 15:11:51.620331+00	2025-06-13 16:49:51.620331+00	f	\N	\N	2025-06-13 15:11:51.61936+00	2025-06-13 15:11:51.61936+00
dda78d2d-9c95-4f10-ba27-838bbeba188d	2	\N	見習い狩人サラ_550	7	47	visiting	\N	2025-06-13 15:11:51.620331+00	2025-06-13 16:57:51.620331+00	f	\N	\N	2025-06-13 15:11:51.61936+00	2025-06-13 15:11:51.61936+00
29838871-09d6-47fc-a8b1-2f0e6c7ec95f	3	\N	魔法学校の生徒リオ_244	6	35	visiting	\N	2025-06-13 15:13:03.633588+00	2025-06-13 16:11:03.633588+00	f	\N	\N	2025-06-13 15:13:03.632809+00	2025-06-13 15:13:03.632809+00
7813d1d2-4609-4bf6-936c-cfedc8553505	3	\N	魔法学校の生徒リオ_368	4	2	visiting	\N	2025-06-13 15:13:03.633588+00	2025-06-13 16:33:03.633588+00	f	\N	\N	2025-06-13 15:13:03.632809+00	2025-06-13 15:13:03.632809+00
382123e0-eae9-4aa5-8286-711fb49c1b89	2	\N	見習い狩人サラ_927	6	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:11:15.427114+00	2025-06-13 15:14:21.476094+00
e2175269-441f-4057-bfc9-79bbe0e47711	2	\N	見習い狩人サラ_332	10	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:23:17.153161+00	2025-06-13 15:14:21.476094+00
66a86992-49c7-4fb8-8886-549a08f333c8	2	\N	見習い狩人サラ_745	7	1	visiting	\N	2025-06-13 15:15:21.55377+00	2025-06-13 17:41:21.55377+00	f	\N	\N	2025-06-13 15:15:21.552848+00	2025-06-13 15:15:21.552848+00
dd7c083a-0f4e-40a0-a2b4-db731974fec0	3	\N	魔法学校の生徒リオ_660	8	26	visiting	\N	2025-06-13 15:17:33.975485+00	2025-06-13 17:53:33.975485+00	f	\N	\N	2025-06-13 15:17:33.974485+00	2025-06-13 15:17:33.974485+00
74810878-2e39-4219-96d0-9f2a2ae15ecf	2	\N	見習い狩人サラ_930	7	29	visiting	\N	2025-06-13 15:17:33.975485+00	2025-06-13 16:59:33.975485+00	f	\N	\N	2025-06-13 15:17:33.974485+00	2025-06-13 15:17:33.974485+00
4e497462-4319-4907-96fd-3959cf54e670	2	\N	見習い狩人サラ_228	9	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:23:49.715906+00	2025-06-13 15:18:03.963239+00
93de4a8a-aca1-428b-b108-d9e5515a77d6	3	\N	魔法学校の生徒リオ_361	6	13	visiting	\N	2025-06-13 15:22:25.931245+00	2025-06-13 17:54:25.931245+00	f	\N	\N	2025-06-13 15:22:25.929883+00	2025-06-13 15:22:25.929883+00
14185f4c-ce43-415d-ae3d-b098609576c0	3	\N	魔法学校の生徒リオ_301	4	31	visiting	\N	2025-06-13 15:22:25.931245+00	2025-06-13 16:43:25.931245+00	f	\N	\N	2025-06-13 15:22:25.929883+00	2025-06-13 15:22:25.929883+00
f04793a8-6c21-4ccd-b50a-775e1e3f8772	3	\N	魔法学校の生徒リオ_802	5	1	visiting	\N	2025-06-13 15:22:25.931245+00	2025-06-13 16:44:25.931245+00	f	\N	\N	2025-06-13 15:22:25.929883+00	2025-06-13 15:22:25.929883+00
5f5b750b-d588-49c5-b954-6c361066de3d	2	\N	見習い狩人サラ_715	10	34	visiting	\N	2025-06-13 15:22:34.004765+00	2025-06-13 16:51:34.004765+00	f	\N	\N	2025-06-13 15:22:34.003784+00	2025-06-13 15:22:34.003784+00
4d56693a-3877-4c57-8193-e131058e801a	2	\N	見習い狩人サラ_626	6	3	visiting	\N	2025-06-13 15:23:34.002875+00	2025-06-13 17:50:34.002875+00	f	\N	\N	2025-06-13 15:23:34.001154+00	2025-06-13 15:23:34.001154+00
fd050aee-3e37-47a8-96e2-75351c96c094	2	\N	見習い狩人サラ_698	6	6	visiting	\N	2025-06-13 15:23:37.997245+00	2025-06-13 16:54:37.997245+00	f	\N	\N	2025-06-13 15:23:37.995696+00	2025-06-13 15:23:37.995696+00
11fb75f7-6d5c-43fe-aeca-d470728b7178	3	\N	魔法学校の生徒リオ_554	7	48	visiting	\N	2025-06-13 15:23:37.997245+00	2025-06-13 18:14:37.997245+00	f	\N	\N	2025-06-13 15:23:37.995696+00	2025-06-13 15:23:37.995696+00
42f19a24-e7b9-4fbf-a675-ca8931057057	2	\N	見習い狩人サラ_213	7	22	visiting	\N	2025-06-13 15:24:03.971565+00	2025-06-13 16:47:03.971565+00	f	\N	\N	2025-06-13 15:24:03.970722+00	2025-06-13 15:24:03.970722+00
6a550249-7b9c-401b-8056-577b7b616a85	2	\N	見習い狩人サラ_800	6	35	visiting	\N	2025-06-13 15:24:03.971565+00	2025-06-13 17:16:03.971565+00	f	\N	\N	2025-06-13 15:24:03.970722+00	2025-06-13 15:24:03.970722+00
33ade5ff-0be1-4693-a820-2912b87ae8b5	3	\N	魔法学校の生徒リオ_427	8	5	visiting	\N	2025-06-13 15:25:02.030705+00	2025-06-13 17:54:02.030705+00	f	\N	\N	2025-06-13 15:25:02.029544+00	2025-06-13 15:25:02.029544+00
90623cbf-f859-49fd-ae0a-6cf84a48f438	3	\N	魔法学校の生徒リオ_175	7	45	visiting	\N	2025-06-13 15:25:02.030705+00	2025-06-13 18:05:02.030705+00	f	\N	\N	2025-06-13 15:25:02.029544+00	2025-06-13 15:25:02.029544+00
93199484-3df1-4ef4-9d0b-3b06c742721e	2	\N	見習い狩人サラ_989	6	32	visiting	\N	2025-06-13 15:25:02.030705+00	2025-06-13 17:11:02.030705+00	f	\N	\N	2025-06-13 15:25:02.029544+00	2025-06-13 15:25:02.029544+00
d9ee3aed-66de-45f8-91b8-e3bf541d26b3	2	\N	見習い狩人サラ_296	7	1	visiting	\N	2025-06-13 15:25:04.003306+00	2025-06-13 16:37:04.003306+00	f	\N	\N	2025-06-13 15:25:04.002315+00	2025-06-13 15:25:04.002315+00
558009a9-dde1-4be1-a1cf-c4c87a5293f1	2	\N	見習い狩人サラ_389	8	26	visiting	\N	2025-06-13 15:25:33.968422+00	2025-06-13 17:32:33.968422+00	f	\N	\N	2025-06-13 15:25:33.967431+00	2025-06-13 15:25:33.967431+00
591ae18f-42ba-424d-bfa2-45f41dba02e6	2	\N	見習い狩人サラ_515	7	16	visiting	\N	2025-06-13 15:25:33.968422+00	2025-06-13 16:16:33.968422+00	f	\N	\N	2025-06-13 15:25:33.967431+00	2025-06-13 15:25:33.967431+00
252e164b-e263-4dd2-a93e-b771ee29c51a	2	\N	見習い狩人サラ_550	9	31	visiting	\N	2025-06-13 15:25:33.968422+00	2025-06-13 16:26:33.968422+00	f	\N	\N	2025-06-13 15:25:33.967431+00	2025-06-13 15:25:33.967431+00
adcd20ef-a4d4-4e9a-b3cf-22a24e36d1ce	3	\N	魔法学校の生徒リオ_944	6	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:48:26.522181+00	2025-06-13 15:43:33.932999+00
4692c6be-d584-42e8-b922-cb2530e26652	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_857	9	7	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:43.94235+00	2025-06-13 05:18:09.743895+00
800d476a-c868-4371-b5dd-559357c76683	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_996	7	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:38:13.918708+00	2025-06-13 05:24:39.71492+00
20a5bbe8-5fea-43d3-a148-75dca466738b	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_457	3	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:02.311751+00	2025-06-13 05:35:06.246555+00
61c63dc0-f1d3-4139-8df8-d0e56fcc8eba	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_348	4	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:56.92433+00	2025-06-13 05:35:06.246555+00
b5d01b89-b5ce-46cc-9223-9127b241f13f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_880	7	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:32.164421+00	2025-06-13 05:35:06.246555+00
0d2e8488-1651-4e68-800e-edda70fee5b1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_43	7	5	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:53:14.015444+00	2025-06-13 05:40:34.521652+00
dcbbc89f-d2b0-4bc5-ac33-b4aef06f86c2	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_97	6	35	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:02:00.26837+00	2025-06-13 05:49:23.933449+00
93e2df74-73d5-495c-8e7e-cf39bda2d814	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_345	7	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:34:13.951578+00	2025-06-13 06:04:43.120378+00
b15ecf9f-3f88-407e-992d-35cca4c38423	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_679	7	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:24.374207+00	2025-06-13 06:24:48.70658+00
220101bb-2135-4805-9483-a5eb2c03f359	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_250	5	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:24.374207+00	2025-06-13 06:32:24.740168+00
ac53f46b-9b01-4b38-b868-b0c2c655b0e1	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_77	4	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.674812+00	2025-06-13 06:33:24.748842+00
1ddec3c4-0e11-44d2-8e20-c3f509b03cd7	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_260	8	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:07.089694+00	2025-06-13 06:35:24.999344+00
4172a863-32fa-4436-a1e3-8e6f703ba8be	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_239	6	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.674812+00	2025-06-13 06:36:24.751982+00
2d788bd1-2eb8-40e7-8d28-ceba9d867b39	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_475	5	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:54.325067+00	2025-06-13 07:13:13.236721+00
31133de0-eff1-4fec-aff8-4b264d1c8b2d	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_147	6	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.858032+00	2025-06-13 07:13:13.236721+00
5e880af4-e8bf-42f8-aa82-576f065f72a4	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_118	6	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:56.80998+00	2025-06-13 07:13:13.236721+00
62418e9d-8e5e-47c9-a3df-0016fcdd2d0a	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_325	6	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.674812+00	2025-06-13 07:13:13.236721+00
7ffc5643-0c0e-438f-955c-0de30d639226	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_768	5	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:54.325067+00	2025-06-13 07:13:13.236721+00
8c56caaf-f5c2-46a3-9666-52bfc3e90b9c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_470	9	16	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:26.851885+00	2025-06-13 07:13:13.236721+00
8e0dc2bf-5a0c-407e-8f39-d77903136d6d	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_132	9	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:13.874397+00	2025-06-13 07:13:13.236721+00
958085ac-2622-4694-8faa-3f8c89a10bf9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_723	4	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:43:01.842236+00	2025-06-13 07:13:13.236721+00
9b27816b-3589-45b2-aeb0-0d042b383517	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_331	7	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:22.976128+00	2025-06-13 07:13:13.236721+00
9c26eeae-92f4-422f-8b47-fc4c0f326b20	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_181	8	21	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:45:56.92433+00	2025-06-13 07:13:13.236721+00
a1fbd70f-bfa8-40cc-8db9-2c2f1a0fd4e4	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_354	3	9	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:54:56.80998+00	2025-06-13 07:13:13.236721+00
ac2fbc87-5d26-486e-bfdd-f9df05c44557	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_866	7	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:54.325067+00	2025-06-13 07:13:13.236721+00
ae17d814-bd02-47df-9f51-15b4ee4f6137	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_695	3	46	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:55:26.818952+00	2025-06-13 07:13:13.236721+00
b1e4a423-2963-4915-91cd-b3ffbf513d6f	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_914	7	22	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:07:24.332606+00	2025-06-13 07:13:13.236721+00
b84f06f5-1312-4a66-aae9-2200819118c6	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_678	3	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:39:13.874397+00	2025-06-13 07:13:13.236721+00
cf2d4fb4-a5f2-46c5-ab73-cc494b6dab98	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_69	4	13	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:49:56.785477+00	2025-06-13 07:13:13.236721+00
d2c58853-ca2b-4d53-a1f6-35c74b57251e	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_293	5	26	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:31:16.201778+00	2025-06-13 07:13:13.236721+00
e9ee9d7f-0002-4e6b-8197-4cf2c5cff9dc	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_596	7	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.858032+00	2025-06-13 07:13:13.236721+00
07fbc2e6-c74b-4fee-a253-588ace21785c	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_211	9	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.715226+00	2025-06-13 07:17:42.133454+00
9456cb9a-3100-4416-b3a8-ef9edf5cf262	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_208	6	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:54.325067+00	2025-06-13 07:44:24.297442+00
c5902bc7-e251-425f-800f-1fabce8edbb5	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_85	6	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.858032+00	2025-06-13 07:46:22.197102+00
0c8b757a-e059-4f86-bfe8-93fc1a26eaf8	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_744	7	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.513912+00	2025-06-13 07:48:22.009169+00
4226735d-60dd-43d9-87c1-19202202eb8b	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_119	6	48	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:22.976128+00	2025-06-13 07:51:52.158531+00
a746cab2-b5bf-4525-99fd-e56cab02ad8f	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_738	5	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:09:54.325067+00	2025-06-13 07:56:22.193449+00
09c7677b-451f-4990-af5a-2b5b2873f062	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_791	3	23	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.715226+00	2025-06-13 08:00:22.38426+00
d6337509-165a-421f-9f49-c07c39ebe54f	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_918	6	39	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:22.976128+00	2025-06-13 08:00:52.197711+00
116ed19c-f03c-49bf-9799-b8a4ab637f0d	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_876	3	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.715226+00	2025-06-13 08:10:22.361248+00
c6c92024-a194-49ec-899b-66449d7cd6fc	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_199	10	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:07.089694+00	2025-06-13 08:11:22.194928+00
b27fc4d9-6ce2-4cbc-9596-45d6a9ab7113	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_897	4	6	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.858032+00	2025-06-13 08:17:22.181157+00
86eb298b-43ee-49df-974e-e30f3e757534	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_145	5	10	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.513912+00	2025-06-13 08:26:18.90567+00
fdde2d0c-98fb-498f-a11c-cf98509c9b79	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_925	6	43	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:22.976128+00	2025-06-13 08:32:39.893817+00
48f57109-ad01-4e11-b2a0-749fb630f468	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_981	5	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:35:06.715226+00	2025-06-13 08:34:09.720923+00
4827c055-e066-4006-b8f6-d299d2689318	2	\N	見習い狩人サラ_99	9	4	visiting	\N	2025-06-13 13:33:08.053707+00	2025-06-13 16:21:08.053707+00	f	\N	\N	2025-06-13 13:33:08.052433+00	2025-06-13 13:33:08.052433+00
e1f5b601-a9af-4962-83fa-7f24bacbf892	3	\N	魔法学校の生徒リオ_12	5	21	visiting	\N	2025-06-13 13:48:27.21718+00	2025-06-13 16:40:27.21718+00	f	\N	\N	2025-06-13 13:48:27.216026+00	2025-06-13 13:48:27.216026+00
632934e2-fa3c-41e1-8292-255556a85a2a	2	\N	見習い狩人サラ_475	8	47	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:02:06.172281+00	2025-06-13 14:52:11.046295+00
59257724-f18e-43a5-a7e7-ac15322ec921	3	\N	魔法学校の生徒リオ_419	5	23	visiting	\N	2025-06-13 14:53:15.890654+00	2025-06-13 17:04:15.890654+00	f	\N	\N	2025-06-13 14:53:15.88957+00	2025-06-13 14:53:15.88957+00
c2062369-3cba-4a8c-9e11-814843f36c9c	2	\N	見習い狩人サラ_574	9	36	visiting	\N	2025-06-13 14:53:15.890654+00	2025-06-13 17:24:15.890654+00	f	\N	\N	2025-06-13 14:53:15.88957+00	2025-06-13 14:53:15.88957+00
e43c4cb2-5562-40b1-82f6-1984fcdcc8cd	3	\N	魔法学校の生徒リオ_733	8	13	visiting	\N	2025-06-13 14:53:15.890654+00	2025-06-13 16:40:15.890654+00	f	\N	\N	2025-06-13 14:53:15.88957+00	2025-06-13 14:53:15.88957+00
7fb0c0db-00d2-4b13-8e25-bd9874a0efa1	2	\N	見習い狩人サラ_640	7	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:48:27.216026+00	2025-06-13 15:13:51.500622+00
f994ec8c-90b0-4274-8789-938eb5aec0d6	3	\N	魔法学校の生徒リオ_846	5	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:24:17.437727+00	2025-06-13 15:14:21.476094+00
0bfb4a8b-8567-4191-b940-01cd1042d5d0	3	\N	魔法学校の生徒リオ_394	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:40.283532+00	2025-06-13 15:16:51.497143+00
2dec2ec5-0a41-4a2d-8ed0-bd0f9182fa01	2	\N	見習い狩人サラ_135	8	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:24:17.437727+00	2025-06-13 15:29:33.932275+00
735ee245-92b3-4c7e-8a6d-70301bc8cf43	2	\N	見習い狩人サラ_276	9	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:48:27.216026+00	2025-06-13 15:30:33.917627+00
f6d19e7b-03f1-47ac-ab87-daee55e92d03	2	\N	見習い狩人サラ_628	8	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:52:40.283532+00	2025-06-13 15:33:03.963355+00
e89231ab-2441-4be6-a0c8-09b6acfbf272	3	\N	魔法学校の生徒リオ_197	6	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:33:08.052433+00	2025-06-13 15:44:33.898822+00
dde4a4d2-ec0d-49f4-ba96-dd177e77106f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_646	9	36	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:51:59.911178+00	2025-06-13 07:13:13.236721+00
e3fe8348-71cc-4b41-bc9d-e8475a679a37	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_540	9	40	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:41:01.841584+00	2025-06-13 07:13:13.236721+00
e869a6f0-9be4-4b4c-85da-f03ac30b92e1	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_423	4	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:01.959179+00	2025-06-13 07:13:13.236721+00
ec63ce83-9c05-4536-8d37-0be63d749732	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_244	10	30	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:30.106607+00	2025-06-13 07:13:13.236721+00
ee97a37f-340b-491f-b442-298f32a34b0f	2	119e86b2-8d18-467c-a6da-09df465a01de	見習い狩人サラ_46	7	3	idle	\N	\N	\N	f	\N	\N	2025-06-13 05:01:30.189023+00	2025-06-13 07:13:13.236721+00
f0cc67e1-a5aa-428f-8a30-e22142c7f639	3	119e86b2-8d18-467c-a6da-09df465a01de	魔法学校の生徒リオ_989	8	38	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:32:13.934877+00	2025-06-13 07:13:13.236721+00
f5bc0ffd-92ad-4a6a-b8f6-8925b57ea0e9	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_868	6	25	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:47:26.920958+00	2025-06-13 07:13:13.236721+00
f65d4f9d-be89-41e9-94a0-da271db92ba2	1	119e86b2-8d18-467c-a6da-09df465a01de	村の少年タム_993	7	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 04:40:31.909496+00	2025-06-13 07:13:13.236721+00
c4f4735f-fb04-4348-af43-611d1f4bb0ba	3	\N	魔法学校の生徒リオ_347	6	46	visiting	\N	2025-06-13 13:03:34.226615+00	2025-06-13 15:46:34.226615+00	f	\N	\N	2025-06-13 13:03:34.225244+00	2025-06-13 13:03:34.225244+00
6305ed81-2920-4824-b25a-23aac1005ae9	1	\N	村の少年タム_493	5	15	visiting	\N	2025-06-13 13:03:34.226615+00	2025-06-13 15:57:34.226615+00	f	\N	\N	2025-06-13 13:03:34.225244+00	2025-06-13 13:03:34.225244+00
fd6cbb45-f121-4864-ab60-b63a6e0c14c9	2	\N	見習い狩人サラ_729	10	18	visiting	\N	2025-06-13 13:24:24.846722+00	2025-06-13 16:07:24.846722+00	f	\N	\N	2025-06-13 13:24:24.844436+00	2025-06-13 13:24:24.844436+00
f456f2df-8abf-465f-866d-45b4e1d8146b	2	\N	見習い狩人サラ_879	6	35	visiting	\N	2025-06-13 13:24:24.846722+00	2025-06-13 15:51:24.846722+00	f	\N	\N	2025-06-13 13:24:24.844436+00	2025-06-13 13:24:24.844436+00
6a389444-3837-4487-8bcb-53511c2f6bcc	1	\N	村の少年タム_520	4	45	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:53:10.282045+00	2025-06-13 13:45:36.442642+00
5fbe56d5-0274-46d9-830a-5a587b9b2dd0	3	\N	魔法学校の生徒リオ_293	8	42	visiting	\N	2025-06-13 13:48:51.690134+00	2025-06-13 16:40:51.690134+00	f	\N	\N	2025-06-13 13:48:51.689208+00	2025-06-13 13:48:51.689208+00
ce4c156d-99b0-4714-b33b-ed0c3b8b9082	2	\N	見習い狩人サラ_194	10	0	visiting	\N	2025-06-13 13:49:17.259096+00	2025-06-13 16:42:17.259096+00	f	\N	\N	2025-06-13 13:49:17.257385+00	2025-06-13 13:49:17.257385+00
64d46c36-4988-4b92-b213-51321279303b	3	\N	魔法学校の生徒リオ_872	7	17	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:54:15.414153+00	2025-06-13 13:51:21.532851+00
08f7c41b-506c-4317-a090-93bdfb7b8e46	3	\N	魔法学校の生徒リオ_856	4	41	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:24:24.844436+00	2025-06-13 14:52:11.046295+00
4b68770b-c073-4fc0-9443-be6ad2961f2e	2	\N	見習い狩人サラ_733	10	50	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:02:15.725282+00	2025-06-13 14:52:11.046295+00
62610295-b1a8-4a95-a213-e8639183c7ff	3	\N	魔法学校の生徒リオ_512	5	44	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:03:15.42959+00	2025-06-13 14:52:11.046295+00
6d599025-b548-475f-bb6c-3daf1eb6b9ef	1	\N	村の少年タム_527	4	18	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:03:45.491135+00	2025-06-13 14:52:11.046295+00
701ecfe4-8bd6-4ab0-ba1b-4a07f73aeb4f	3	\N	魔法学校の生徒リオ_69	6	8	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:55:15.502017+00	2025-06-13 14:52:11.046295+00
cd328608-73fd-410f-bbc4-32567b2e5cae	1	\N	村の少年タム_849	5	14	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:03:34.225244+00	2025-06-13 14:52:11.046295+00
334e2d03-9a58-4df1-99ae-130f6c866abf	2	\N	見習い狩人サラ_851	9	18	visiting	\N	2025-06-13 14:53:41.053304+00	2025-06-13 17:29:41.053304+00	f	\N	\N	2025-06-13 14:53:41.052279+00	2025-06-13 14:53:41.052279+00
6c193338-a8b1-4292-8e46-5c12aad365ba	3	\N	魔法学校の生徒リオ_188	4	48	visiting	\N	2025-06-13 14:53:41.053304+00	2025-06-13 16:04:41.053304+00	f	\N	\N	2025-06-13 14:53:41.052279+00	2025-06-13 14:53:41.052279+00
0b100c6b-b32b-4912-bc00-e0b180d1e32f	3	\N	魔法学校の生徒リオ_916	4	27	visiting	\N	2025-06-13 14:54:11.061265+00	2025-06-13 16:50:11.061265+00	f	\N	\N	2025-06-13 14:54:11.060116+00	2025-06-13 14:54:11.060116+00
daec4287-2148-4b20-9346-f6ba9a9f2e6c	3	\N	魔法学校の生徒リオ_446	4	47	visiting	\N	2025-06-13 14:54:11.061265+00	2025-06-13 15:54:11.061265+00	f	\N	\N	2025-06-13 14:54:11.060116+00	2025-06-13 14:54:11.060116+00
49a4a909-76c7-4000-bdd4-554d3c05aef6	3	\N	魔法学校の生徒リオ_446	5	20	visiting	\N	2025-06-13 14:54:41.49191+00	2025-06-13 16:48:41.49191+00	f	\N	\N	2025-06-13 14:54:41.490573+00	2025-06-13 14:54:41.490573+00
96058d0d-f579-4464-9677-22b4cb24e7eb	2	\N	見習い狩人サラ_474	7	19	visiting	\N	2025-06-13 14:58:41.011871+00	2025-06-13 15:55:41.011871+00	f	\N	\N	2025-06-13 14:58:41.010659+00	2025-06-13 14:58:41.010659+00
102667d5-a780-4cb7-9320-feb9978f19cc	3	\N	魔法学校の生徒リオ_347	8	41	visiting	\N	2025-06-13 14:58:41.011871+00	2025-06-13 17:54:41.011871+00	f	\N	\N	2025-06-13 14:58:41.010659+00	2025-06-13 14:58:41.010659+00
6cedcf94-8f8f-422d-9502-ca3760389b35	3	\N	魔法学校の生徒リオ_345	5	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:53:10.282045+00	2025-06-13 15:02:10.938142+00
5f01f595-44bb-4d54-a098-5766df2e74f8	2	\N	見習い狩人サラ_73	9	39	visiting	\N	2025-06-13 15:08:57.3538+00	2025-06-13 18:04:57.3538+00	f	\N	\N	2025-06-13 15:08:57.351729+00	2025-06-13 15:08:57.351729+00
21aa774b-13f6-44ad-a6ce-09f919cbc8cd	3	\N	魔法学校の生徒リオ_828	8	17	visiting	\N	2025-06-13 15:08:57.3538+00	2025-06-13 16:54:57.3538+00	f	\N	\N	2025-06-13 15:08:57.351729+00	2025-06-13 15:08:57.351729+00
f0432ca7-b479-442e-b7f0-ed3a9bb63bea	2	\N	見習い狩人サラ_264	9	34	visiting	\N	2025-06-13 15:08:57.3538+00	2025-06-13 16:01:57.3538+00	f	\N	\N	2025-06-13 15:08:57.351729+00	2025-06-13 15:08:57.351729+00
ca88931a-afa9-4e51-bac6-3255643bf5a7	3	\N	魔法学校の生徒リオ_86	4	46	visiting	\N	2025-06-13 15:09:21.495405+00	2025-06-13 16:57:21.495405+00	f	\N	\N	2025-06-13 15:09:21.493841+00	2025-06-13 15:09:21.493841+00
fb4ac901-ad18-4075-92bd-abbb1ecac180	2	\N	見習い狩人サラ_254	6	9	visiting	\N	2025-06-13 15:09:21.495405+00	2025-06-13 16:50:21.495405+00	f	\N	\N	2025-06-13 15:09:21.493841+00	2025-06-13 15:09:21.493841+00
ef78ca09-4fd5-4630-a23e-e0c1a88666c4	2	\N	見習い狩人サラ_848	7	35	visiting	\N	2025-06-13 15:09:21.495405+00	2025-06-13 16:52:21.495405+00	f	\N	\N	2025-06-13 15:09:21.493841+00	2025-06-13 15:09:21.493841+00
b3137232-a1b4-4ef6-aa58-e4babd85ab53	2	\N	見習い狩人サラ_215	8	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:32:23.017676+00	2025-06-13 15:11:51.520475+00
6cf23abb-0a01-42d4-90dc-3c89e3f46e8b	3	\N	魔法学校の生徒リオ_749	4	41	visiting	\N	2025-06-13 15:13:21.575437+00	2025-06-13 17:06:21.575437+00	f	\N	\N	2025-06-13 15:13:21.574328+00	2025-06-13 15:13:21.574328+00
7e0f2e19-5aec-4c1f-9799-fa84cee03b5c	2	\N	見習い狩人サラ_847	6	33	visiting	\N	2025-06-13 15:13:21.575437+00	2025-06-13 18:11:21.575437+00	f	\N	\N	2025-06-13 15:13:21.574328+00	2025-06-13 15:13:21.574328+00
bdd2ee2c-ecf7-44de-a621-04ccf9972b84	3	\N	魔法学校の生徒リオ_293	8	21	visiting	\N	2025-06-13 15:13:21.575437+00	2025-06-13 17:15:21.575437+00	f	\N	\N	2025-06-13 15:13:21.574328+00	2025-06-13 15:13:21.574328+00
ee751a29-1bdf-47fd-a94a-a4c8192527da	2	\N	見習い狩人サラ_216	8	49	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:34:07.799438+00	2025-06-13 15:14:21.476094+00
7b5d65dc-dcf9-495c-bb22-854d5d6692cf	2	\N	見習い狩人サラ_783	10	16	visiting	\N	2025-06-13 15:15:39.682921+00	2025-06-13 17:51:39.682921+00	f	\N	\N	2025-06-13 15:15:39.68066+00	2025-06-13 15:15:39.68066+00
39987ec6-c15d-4fb5-85e5-33fa1b557279	2	\N	見習い狩人サラ_682	7	50	visiting	\N	2025-06-13 15:15:39.682921+00	2025-06-13 16:48:39.682921+00	f	\N	\N	2025-06-13 15:15:39.68066+00	2025-06-13 15:15:39.68066+00
2d54e7e3-639a-45f3-8fb5-88c7a84c6f0a	2	\N	見習い狩人サラ_485	7	0	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:03:45.491135+00	2025-06-13 15:15:51.462837+00
28a78291-6fd0-4014-8fc1-80f0a7898e61	2	\N	見習い狩人サラ_853	10	29	visiting	\N	2025-06-13 15:15:51.567575+00	2025-06-13 16:24:51.567575+00	f	\N	\N	2025-06-13 15:15:51.566621+00	2025-06-13 15:15:51.566621+00
0c59d780-0d37-4025-96c7-2027a552a0fc	2	\N	見習い狩人サラ_732	9	8	visiting	\N	2025-06-13 15:15:51.567575+00	2025-06-13 17:01:51.567575+00	f	\N	\N	2025-06-13 15:15:51.566621+00	2025-06-13 15:15:51.566621+00
bbef1c63-ba44-4f9d-b8d2-ad5f19ce0a0a	3	\N	魔法学校の生徒リオ_386	5	39	visiting	\N	2025-06-13 15:17:04.009788+00	2025-06-13 16:31:04.009788+00	f	\N	\N	2025-06-13 15:17:04.008447+00	2025-06-13 15:17:04.008447+00
20a235a6-3276-47ab-b4ba-26d475985d8e	3	\N	魔法学校の生徒リオ_862	6	45	visiting	\N	2025-06-13 15:18:34.037576+00	2025-06-13 18:13:34.037576+00	f	\N	\N	2025-06-13 15:18:34.036607+00	2025-06-13 15:18:34.036607+00
f4663dcb-883c-4b2d-aad1-91d67164b81f	2	\N	見習い狩人サラ_449	7	16	visiting	\N	2025-06-13 15:20:34.039803+00	2025-06-13 18:15:34.039803+00	f	\N	\N	2025-06-13 15:20:34.038198+00	2025-06-13 15:20:34.038198+00
2938c441-dbde-4d6e-8dbd-55bcc8ac9e29	2	\N	見習い狩人サラ_745	8	42	visiting	\N	2025-06-13 15:20:34.039803+00	2025-06-13 18:19:34.039803+00	f	\N	\N	2025-06-13 15:20:34.038198+00	2025-06-13 15:20:34.038198+00
21e1539a-614e-4418-9fbf-b0d678ed1da8	3	\N	魔法学校の生徒リオ_779	6	20	visiting	\N	2025-06-13 15:20:34.039803+00	2025-06-13 16:41:34.039803+00	f	\N	\N	2025-06-13 15:20:34.038198+00	2025-06-13 15:20:34.038198+00
fcd80279-5a5d-4a6e-8841-30d840242f9a	2	\N	見習い狩人サラ_832	6	33	visiting	\N	2025-06-13 15:21:33.98782+00	2025-06-13 16:25:33.98782+00	f	\N	\N	2025-06-13 15:21:33.986785+00	2025-06-13 15:21:33.986785+00
484489cf-d23a-4283-979a-7e5d589d5839	2	\N	見習い狩人サラ_585	9	36	visiting	\N	2025-06-13 15:24:34.031644+00	2025-06-13 18:09:34.031644+00	f	\N	\N	2025-06-13 15:24:34.030619+00	2025-06-13 15:24:34.030619+00
05d8780d-464e-4413-9674-4fc58407480e	3	\N	魔法学校の生徒リオ_84	4	19	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:03:45.491135+00	2025-06-13 15:34:03.893434+00
8dc6b5ae-fa8e-464d-b2d1-afaaf393453a	3	\N	魔法学校の生徒リオ_920	5	42	idle	\N	\N	\N	f	\N	\N	2025-06-13 12:55:15.502017+00	2025-06-13 15:39:33.940158+00
220dd0c9-9462-47f9-87a5-db99b8c21d40	2	\N	見習い狩人サラ_145	10	33	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:02:15.725282+00	2025-06-13 15:41:33.931033+00
8817810f-dc3b-412e-8e4b-fd09e8c7cdd1	3	\N	魔法学校の生徒リオ_542	5	37	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:53:41.052279+00	2025-06-13 15:43:03.978781+00
9aa33a07-87f3-4fcf-87f4-0399f064c181	3	\N	魔法学校の生徒リオ_268	5	7	visiting	\N	2025-06-13 15:25:51.064114+00	2025-06-13 18:14:51.064114+00	f	\N	\N	2025-06-13 15:25:51.062586+00	2025-06-13 15:25:51.062586+00
98441486-cffa-43d1-a62f-9ed3768bdee3	3	\N	魔法学校の生徒リオ_578	6	40	visiting	\N	2025-06-13 15:25:51.064114+00	2025-06-13 18:25:51.064114+00	f	\N	\N	2025-06-13 15:25:51.062586+00	2025-06-13 15:25:51.062586+00
c28c5bf0-e20f-49ae-995f-5864090329d9	3	\N	魔法学校の生徒リオ_629	5	31	visiting	\N	2025-06-13 15:27:03.959486+00	2025-06-13 16:45:03.959486+00	f	\N	\N	2025-06-13 15:27:03.95847+00	2025-06-13 15:27:03.95847+00
fdc1a491-5b5e-4ab8-b223-8340b78b9278	3	\N	魔法学校の生徒リオ_453	4	47	visiting	\N	2025-06-13 15:26:03.955434+00	2025-06-13 16:21:03.955434+00	f	\N	\N	2025-06-13 15:26:03.954397+00	2025-06-13 15:26:03.954397+00
31810352-0459-4d44-9e30-85ac620e21dc	3	\N	魔法学校の生徒リオ_798	6	32	idle	\N	\N	\N	f	\N	\N	2025-06-13 13:49:17.257385+00	2025-06-13 15:27:33.906449+00
2244eb5b-3217-41fc-b197-8b8aebe5a240	2	\N	見習い狩人サラ_188	9	9	visiting	\N	2025-06-13 15:27:34.014081+00	2025-06-13 17:48:34.014081+00	f	\N	\N	2025-06-13 15:27:34.013103+00	2025-06-13 15:27:34.013103+00
3e2dd72d-6786-4c2f-afd9-07a0464732c7	2	\N	見習い狩人サラ_691	6	16	visiting	\N	2025-06-13 15:27:34.014081+00	2025-06-13 16:57:34.014081+00	f	\N	\N	2025-06-13 15:27:34.013103+00	2025-06-13 15:27:34.013103+00
0abaf9dd-e487-4863-8e69-d07b817760ec	3	\N	魔法学校の生徒リオ_506	6	13	visiting	\N	2025-06-13 15:26:34.037871+00	2025-06-13 17:09:34.037871+00	f	\N	\N	2025-06-13 15:26:34.036585+00	2025-06-13 15:26:34.036585+00
80b67976-23bd-49a2-a594-4b8d9126f6a7	2	\N	見習い狩人サラ_294	10	23	visiting	\N	2025-06-13 15:27:26.120503+00	2025-06-13 18:09:26.120503+00	f	\N	\N	2025-06-13 15:27:26.119011+00	2025-06-13 15:27:26.119011+00
8c71a344-c3c9-47d4-a002-d4e273cfea54	2	\N	見習い狩人サラ_76	6	46	visiting	\N	2025-06-13 15:27:26.120503+00	2025-06-13 17:58:26.120503+00	f	\N	\N	2025-06-13 15:27:26.119011+00	2025-06-13 15:27:26.119011+00
63d40969-c057-48d8-874f-ac2d2d721786	2	\N	見習い狩人サラ_96	10	9	visiting	\N	2025-06-13 15:27:26.120503+00	2025-06-13 16:55:26.120503+00	f	\N	\N	2025-06-13 15:27:26.119011+00	2025-06-13 15:27:26.119011+00
e7808757-0a4f-40ac-9e7f-0b2aa2ca1637	2	\N	見習い狩人サラ_10	7	1	visiting	\N	2025-06-13 15:28:03.990548+00	2025-06-13 17:41:03.990548+00	f	\N	\N	2025-06-13 15:28:03.989595+00	2025-06-13 15:28:03.989595+00
591f6b6b-0bb4-4c55-8462-a2aa97a30e74	2	\N	見習い狩人サラ_592	6	32	visiting	\N	2025-06-13 15:28:03.990548+00	2025-06-13 16:48:03.990548+00	f	\N	\N	2025-06-13 15:28:03.989595+00	2025-06-13 15:28:03.989595+00
486b175f-4161-421c-bf86-9efebe9a3e3a	3	\N	魔法学校の生徒リオ_460	5	43	visiting	\N	2025-06-13 15:28:33.953941+00	2025-06-13 16:40:33.953941+00	f	\N	\N	2025-06-13 15:28:33.952938+00	2025-06-13 15:28:33.952938+00
056156a9-78c6-4471-a097-8c37c258c7ee	3	\N	魔法学校の生徒リオ_709	4	47	visiting	\N	2025-06-13 15:28:33.953941+00	2025-06-13 18:27:33.953941+00	f	\N	\N	2025-06-13 15:28:33.952938+00	2025-06-13 15:28:33.952938+00
2e019e94-0858-48be-a713-4a506d28af12	3	\N	魔法学校の生徒リオ_43	4	45	visiting	\N	2025-06-13 15:28:55.177831+00	2025-06-13 17:30:55.177831+00	f	\N	\N	2025-06-13 15:28:55.176662+00	2025-06-13 15:28:55.176662+00
72c6ada9-5ebb-4516-bb81-8ffeb3871144	2	\N	見習い狩人サラ_682	8	19	visiting	\N	2025-06-13 15:28:55.177831+00	2025-06-13 18:21:55.177831+00	f	\N	\N	2025-06-13 15:28:55.176662+00	2025-06-13 15:28:55.176662+00
9e9b0322-5f6a-4942-80d2-80b4993f3b47	3	\N	魔法学校の生徒リオ_996	8	27	visiting	\N	2025-06-13 15:29:04.00757+00	2025-06-13 16:39:04.00757+00	f	\N	\N	2025-06-13 15:29:04.006647+00	2025-06-13 15:29:04.006647+00
1f831890-3c94-48e2-89cf-294fb2e4c263	2	\N	見習い狩人サラ_207	6	14	visiting	\N	2025-06-13 15:29:04.00757+00	2025-06-13 17:02:04.00757+00	f	\N	\N	2025-06-13 15:29:04.006647+00	2025-06-13 15:29:04.006647+00
ac4ec242-8a2d-4b2a-8e1a-0b9aad13720d	3	\N	魔法学校の生徒リオ_571	8	48	visiting	\N	2025-06-13 15:29:33.424148+00	2025-06-13 17:31:33.424148+00	f	\N	\N	2025-06-13 15:29:33.417456+00	2025-06-13 15:29:33.417456+00
5c4f7576-4069-48dc-92ac-3667166bd15b	3	\N	魔法学校の生徒リオ_400	4	19	visiting	\N	2025-06-13 15:29:34.052924+00	2025-06-13 18:00:34.052924+00	f	\N	\N	2025-06-13 15:29:34.051856+00	2025-06-13 15:29:34.051856+00
41955d2f-5787-458e-8e10-dec9ddbff1b2	2	\N	見習い狩人サラ_870	9	17	visiting	\N	2025-06-13 15:29:34.052924+00	2025-06-13 18:06:34.052924+00	f	\N	\N	2025-06-13 15:29:34.051856+00	2025-06-13 15:29:34.051856+00
7ab9cecb-369d-495e-a3f7-cdd814633b76	3	\N	魔法学校の生徒リオ_607	4	3	visiting	\N	2025-06-13 15:30:04.015369+00	2025-06-13 17:59:04.015369+00	f	\N	\N	2025-06-13 15:30:04.014388+00	2025-06-13 15:30:04.014388+00
e9f6ba84-b952-4578-bc03-ca4779987f96	2	\N	見習い狩人サラ_618	9	38	visiting	\N	2025-06-13 15:30:04.015369+00	2025-06-13 17:40:04.015369+00	f	\N	\N	2025-06-13 15:30:04.014388+00	2025-06-13 15:30:04.014388+00
8f02addb-0a97-49c1-895e-236eb36c6fb0	2	\N	見習い狩人サラ_522	7	1	visiting	\N	2025-06-13 15:30:33.995286+00	2025-06-13 16:36:33.995286+00	f	\N	\N	2025-06-13 15:30:33.994104+00	2025-06-13 15:30:33.994104+00
be939a78-7ac7-4c94-851d-68fbc3191047	3	\N	魔法学校の生徒リオ_148	7	12	visiting	\N	2025-06-13 15:31:03.961279+00	2025-06-13 16:41:03.961279+00	f	\N	\N	2025-06-13 15:31:03.960108+00	2025-06-13 15:31:03.960108+00
bfb4d0d4-0c16-4018-a1b8-71a117ba7d57	2	\N	見習い狩人サラ_532	9	26	visiting	\N	2025-06-13 15:31:03.961279+00	2025-06-13 18:29:03.961279+00	f	\N	\N	2025-06-13 15:31:03.960108+00	2025-06-13 15:31:03.960108+00
2c5d2fd6-23e0-40c1-b769-ae345a224e35	2	\N	見習い狩人サラ_401	9	17	visiting	\N	2025-06-13 15:31:03.961279+00	2025-06-13 18:16:03.961279+00	f	\N	\N	2025-06-13 15:31:03.960108+00	2025-06-13 15:31:03.960108+00
f2b323b1-f6a6-488c-8097-e86e8fa0c405	2	\N	見習い狩人サラ_149	9	32	visiting	\N	2025-06-13 15:31:19.78006+00	2025-06-13 18:24:19.78006+00	f	\N	\N	2025-06-13 15:31:19.77682+00	2025-06-13 15:31:19.77682+00
e0bf8f0d-4b8c-44ab-af7d-94bc52e60bac	2	\N	見習い狩人サラ_469	6	17	visiting	\N	2025-06-13 15:31:19.78006+00	2025-06-13 16:16:19.78006+00	f	\N	\N	2025-06-13 15:31:19.77682+00	2025-06-13 15:31:19.77682+00
f6e66cff-4978-482b-9e65-2868f7287d77	3	\N	魔法学校の生徒リオ_705	8	0	visiting	\N	2025-06-13 15:31:19.78006+00	2025-06-13 17:51:19.78006+00	f	\N	\N	2025-06-13 15:31:19.77682+00	2025-06-13 15:31:19.77682+00
fe03c23d-51dc-46de-b5d5-2ec0d024e23e	2	\N	見習い狩人サラ_190	6	45	visiting	\N	2025-06-13 15:31:34.082829+00	2025-06-13 17:54:34.082829+00	f	\N	\N	2025-06-13 15:31:34.081186+00	2025-06-13 15:31:34.081186+00
902c0602-f1b9-470d-990c-11872662cf23	3	\N	魔法学校の生徒リオ_253	6	23	visiting	\N	2025-06-13 15:31:34.082829+00	2025-06-13 16:19:34.082829+00	f	\N	\N	2025-06-13 15:31:34.081186+00	2025-06-13 15:31:34.081186+00
d7a7160f-843d-401a-88c6-6b8901c9da16	3	\N	魔法学校の生徒リオ_974	7	3	visiting	\N	2025-06-13 15:31:34.082829+00	2025-06-13 17:16:34.082829+00	f	\N	\N	2025-06-13 15:31:34.081186+00	2025-06-13 15:31:34.081186+00
0e907d4c-9213-4d07-be09-b912b7cbdf9b	3	\N	魔法学校の生徒リオ_597	7	36	visiting	\N	2025-06-13 15:32:06.346871+00	2025-06-13 18:23:06.346871+00	f	\N	\N	2025-06-13 15:32:06.345937+00	2025-06-13 15:32:06.345937+00
16795bfd-c7f2-4a2b-a3f2-c40b6908d087	3	\N	魔法学校の生徒リオ_26	6	5	visiting	\N	2025-06-13 15:32:06.346871+00	2025-06-13 18:15:06.346871+00	f	\N	\N	2025-06-13 15:32:06.345937+00	2025-06-13 15:32:06.345937+00
b44025e7-1dc7-481d-8306-82b1a46122fa	3	\N	魔法学校の生徒リオ_837	8	38	visiting	\N	2025-06-13 15:32:46.060919+00	2025-06-13 18:09:46.060919+00	f	\N	\N	2025-06-13 15:32:46.058344+00	2025-06-13 15:32:46.058344+00
e7550e70-59a2-404f-83e7-b5a5be291135	2	\N	見習い狩人サラ_938	10	5	visiting	\N	2025-06-13 15:32:46.060919+00	2025-06-13 18:29:46.060919+00	f	\N	\N	2025-06-13 15:32:46.058344+00	2025-06-13 15:32:46.058344+00
14d096ef-02d4-48c9-98d2-7a5c54039995	2	\N	見習い狩人サラ_121	10	7	visiting	\N	2025-06-13 15:32:46.060919+00	2025-06-13 16:43:46.060919+00	f	\N	\N	2025-06-13 15:32:46.058344+00	2025-06-13 15:32:46.058344+00
925b500e-a331-46da-ac98-3300f456a42b	3	\N	魔法学校の生徒リオ_778	4	24	visiting	\N	2025-06-13 15:33:04.053931+00	2025-06-13 16:29:04.053931+00	f	\N	\N	2025-06-13 15:33:04.052905+00	2025-06-13 15:33:04.052905+00
21fcfc1b-d84b-4fe2-9d60-19dc7f358f99	3	\N	魔法学校の生徒リオ_285	7	39	visiting	\N	2025-06-13 15:33:04.053931+00	2025-06-13 17:08:04.053931+00	f	\N	\N	2025-06-13 15:33:04.052905+00	2025-06-13 15:33:04.052905+00
340d42f3-d6b8-4935-b9ca-7d95e8f45fbb	3	\N	魔法学校の生徒リオ_797	4	45	visiting	\N	2025-06-13 15:33:04.053931+00	2025-06-13 17:50:04.053931+00	f	\N	\N	2025-06-13 15:33:04.052905+00	2025-06-13 15:33:04.052905+00
6275ed53-6d6b-401b-8d4d-98286dae2b8f	2	\N	見習い狩人サラ_390	10	46	visiting	\N	2025-06-13 15:33:34.286236+00	2025-06-13 17:22:34.286236+00	f	\N	\N	2025-06-13 15:33:34.285251+00	2025-06-13 15:33:34.285251+00
42748848-8a3e-44b9-9889-ff5ac90cea24	2	\N	見習い狩人サラ_856	9	43	visiting	\N	2025-06-13 15:33:34.286236+00	2025-06-13 16:44:34.286236+00	f	\N	\N	2025-06-13 15:33:34.285251+00	2025-06-13 15:33:34.285251+00
46a10921-cf0f-430f-a573-d5a3b6cddd77	3	\N	魔法学校の生徒リオ_32	4	38	visiting	\N	2025-06-13 15:34:04.014344+00	2025-06-13 16:33:04.014344+00	f	\N	\N	2025-06-13 15:34:04.013049+00	2025-06-13 15:34:04.013049+00
0be94227-0312-49bc-95a8-e62e805c9f75	3	\N	魔法学校の生徒リオ_577	6	30	visiting	\N	2025-06-13 15:34:04.014344+00	2025-06-13 16:41:04.014344+00	f	\N	\N	2025-06-13 15:34:04.013049+00	2025-06-13 15:34:04.013049+00
c8fb727d-a725-470c-aa7b-b5857041ffbc	3	\N	魔法学校の生徒リオ_973	4	46	visiting	\N	2025-06-13 15:34:04.014344+00	2025-06-13 17:12:04.014344+00	f	\N	\N	2025-06-13 15:34:04.013049+00	2025-06-13 15:34:04.013049+00
5f779222-9c4a-4b54-b480-090cbfd295d8	3	\N	魔法学校の生徒リオ_791	7	46	visiting	\N	2025-06-13 15:34:06.123924+00	2025-06-13 16:37:06.123924+00	f	\N	\N	2025-06-13 15:34:06.122791+00	2025-06-13 15:34:06.122791+00
b2cbcade-4111-4260-9546-e3f068aebd77	2	\N	見習い狩人サラ_590	7	45	visiting	\N	2025-06-13 15:34:06.123924+00	2025-06-13 16:48:06.123924+00	f	\N	\N	2025-06-13 15:34:06.122791+00	2025-06-13 15:34:06.122791+00
38b4b075-b898-4608-bed8-91dcf5db7242	3	\N	魔法学校の生徒リオ_747	8	49	visiting	\N	2025-06-13 15:34:06.123924+00	2025-06-13 17:00:06.123924+00	f	\N	\N	2025-06-13 15:34:06.122791+00	2025-06-13 15:34:06.122791+00
64b1d544-f1f1-48a8-a34e-4bba74cefa67	2	\N	見習い狩人サラ_102	6	48	visiting	\N	2025-06-13 15:34:33.998478+00	2025-06-13 17:04:33.998478+00	f	\N	\N	2025-06-13 15:34:33.9975+00	2025-06-13 15:34:33.9975+00
26c1a8d4-44fc-42a0-a35c-d00c667706c0	3	\N	魔法学校の生徒リオ_954	5	43	visiting	\N	2025-06-13 15:34:33.998478+00	2025-06-13 17:38:33.998478+00	f	\N	\N	2025-06-13 15:34:33.9975+00	2025-06-13 15:34:33.9975+00
e8ebd75d-0d1d-4ad9-aaeb-351ee26f3d94	3	\N	魔法学校の生徒リオ_279	6	6	visiting	\N	2025-06-13 15:34:58.164961+00	2025-06-13 17:05:58.164961+00	f	\N	\N	2025-06-13 15:34:58.163967+00	2025-06-13 15:34:58.163967+00
870c2893-b8b9-449c-9b46-22fdb42b2513	2	\N	見習い狩人サラ_995	10	5	visiting	\N	2025-06-13 15:35:03.964975+00	2025-06-13 18:25:03.964975+00	f	\N	\N	2025-06-13 15:35:03.963841+00	2025-06-13 15:35:03.963841+00
d575c319-ae06-4f62-8fe0-88f0f150acdd	3	\N	魔法学校の生徒リオ_254	7	26	visiting	\N	2025-06-13 15:35:34.277415+00	2025-06-13 17:13:34.277415+00	f	\N	\N	2025-06-13 15:35:34.27587+00	2025-06-13 15:35:34.27587+00
dfd6416c-a68b-4579-b292-431e4da86dc8	2	\N	見習い狩人サラ_247	9	26	visiting	\N	2025-06-13 15:36:04.012461+00	2025-06-13 18:36:04.012461+00	f	\N	\N	2025-06-13 15:36:04.011312+00	2025-06-13 15:36:04.011312+00
7d5568d9-f3e7-4633-8e2d-9d7bcbcd5d89	2	\N	見習い狩人サラ_944	6	19	visiting	\N	2025-06-13 15:36:34.287553+00	2025-06-13 17:28:34.287553+00	f	\N	\N	2025-06-13 15:36:34.286588+00	2025-06-13 15:36:34.286588+00
38aad4c0-17c3-4a57-a105-fa35884206a3	3	\N	魔法学校の生徒リオ_916	5	34	visiting	\N	2025-06-13 15:36:34.287553+00	2025-06-13 17:05:34.287553+00	f	\N	\N	2025-06-13 15:36:34.286588+00	2025-06-13 15:36:34.286588+00
71df6c18-6a64-4bd1-af62-6b5c73edbfc7	3	\N	魔法学校の生徒リオ_250	5	6	visiting	\N	2025-06-13 15:36:34.287553+00	2025-06-13 17:41:34.287553+00	f	\N	\N	2025-06-13 15:36:34.286588+00	2025-06-13 15:36:34.286588+00
f31fc57f-d5e3-489c-bd69-a550544eea13	3	\N	魔法学校の生徒リオ_437	5	38	visiting	\N	2025-06-13 15:36:49.189512+00	2025-06-13 17:27:49.189512+00	f	\N	\N	2025-06-13 15:36:49.188236+00	2025-06-13 15:36:49.188236+00
8f13fd1c-fc0b-4326-8fd6-0ecc291b15bd	2	\N	見習い狩人サラ_181	6	50	visiting	\N	2025-06-13 15:37:04.020726+00	2025-06-13 17:44:04.020726+00	f	\N	\N	2025-06-13 15:37:04.019699+00	2025-06-13 15:37:04.019699+00
766506d7-ebab-4e2a-adba-53ff6652cf8e	3	\N	魔法学校の生徒リオ_264	6	2	visiting	\N	2025-06-13 15:37:25.248403+00	2025-06-13 17:44:25.248403+00	f	\N	\N	2025-06-13 15:37:25.246648+00	2025-06-13 15:37:25.246648+00
20f83d56-e7fb-48a6-bfb9-93f1339c8261	3	\N	魔法学校の生徒リオ_975	5	5	visiting	\N	2025-06-13 15:37:34.045608+00	2025-06-13 16:22:34.045608+00	f	\N	\N	2025-06-13 15:37:34.044751+00	2025-06-13 15:37:34.044751+00
7696893c-fc61-45ec-b905-6b073b39f925	3	\N	魔法学校の生徒リオ_851	6	37	visiting	\N	2025-06-13 15:37:34.045608+00	2025-06-13 18:10:34.045608+00	f	\N	\N	2025-06-13 15:37:34.044751+00	2025-06-13 15:37:34.044751+00
ee56c49a-5043-4170-b9bd-d2b63aa304cd	2	\N	見習い狩人サラ_350	9	13	visiting	\N	2025-06-13 15:37:34.045608+00	2025-06-13 18:36:34.045608+00	f	\N	\N	2025-06-13 15:37:34.044751+00	2025-06-13 15:37:34.044751+00
0d59aa65-4446-4e98-92a8-da2c7b243dc9	2	\N	見習い狩人サラ_883	8	21	visiting	\N	2025-06-13 15:38:06.792662+00	2025-06-13 18:24:06.792662+00	f	\N	\N	2025-06-13 15:38:06.791231+00	2025-06-13 15:38:06.791231+00
80e4bfb4-6e9d-499f-a1a6-f06ab64616ed	2	\N	見習い狩人サラ_646	6	35	visiting	\N	2025-06-13 15:38:06.792662+00	2025-06-13 17:53:06.792662+00	f	\N	\N	2025-06-13 15:38:06.791231+00	2025-06-13 15:38:06.791231+00
52872eca-3e3b-48f9-9f9e-774d3ed940cc	2	\N	見習い狩人サラ_913	10	36	visiting	\N	2025-06-13 15:38:06.792662+00	2025-06-13 18:18:06.792662+00	f	\N	\N	2025-06-13 15:38:06.791231+00	2025-06-13 15:38:06.791231+00
4d0376a7-448d-4529-ab22-5600d6179f9d	2	\N	見習い狩人サラ_764	7	37	visiting	\N	2025-06-13 15:38:27.734124+00	2025-06-13 16:39:27.734124+00	f	\N	\N	2025-06-13 15:38:27.732002+00	2025-06-13 15:38:27.732002+00
b5b16c18-90d1-4a30-90ff-f616fc1558ee	3	\N	魔法学校の生徒リオ_109	8	33	visiting	\N	2025-06-13 15:38:34.123111+00	2025-06-13 16:25:34.123111+00	f	\N	\N	2025-06-13 15:38:34.122262+00	2025-06-13 15:38:34.122262+00
e880e8e3-d911-407b-aa22-0ad3756bba82	3	\N	魔法学校の生徒リオ_411	4	34	visiting	\N	2025-06-13 15:39:04.280389+00	2025-06-13 17:46:04.280389+00	f	\N	\N	2025-06-13 15:39:04.278883+00	2025-06-13 15:39:04.278883+00
95888d22-e9ad-43d5-ae3d-bd4f9805545e	2	\N	見習い狩人サラ_688	8	49	visiting	\N	2025-06-13 15:39:04.280389+00	2025-06-13 16:58:04.280389+00	f	\N	\N	2025-06-13 15:39:04.278883+00	2025-06-13 15:39:04.278883+00
b3446ac8-902f-4e5f-82c9-b47f55b9b643	3	\N	魔法学校の生徒リオ_939	4	47	visiting	\N	2025-06-13 15:39:09.77146+00	2025-06-13 18:02:09.77146+00	f	\N	\N	2025-06-13 15:39:09.769452+00	2025-06-13 15:39:09.769452+00
38814b55-6a12-4ff0-b707-468015558589	2	\N	見習い狩人サラ_748	10	32	visiting	\N	2025-06-13 15:39:09.77146+00	2025-06-13 16:39:09.77146+00	f	\N	\N	2025-06-13 15:39:09.769452+00	2025-06-13 15:39:09.769452+00
682bfbd7-8a39-43f5-9c09-c0c2b651a611	2	\N	見習い狩人サラ_431	9	29	visiting	\N	2025-06-13 15:39:09.77146+00	2025-06-13 17:35:09.77146+00	f	\N	\N	2025-06-13 15:39:09.769452+00	2025-06-13 15:39:09.769452+00
e1c7769f-87de-4ba8-b60b-163a8afc7619	3	\N	魔法学校の生徒リオ_820	4	35	visiting	\N	2025-06-13 15:39:34.026014+00	2025-06-13 17:59:34.026014+00	f	\N	\N	2025-06-13 15:39:34.025269+00	2025-06-13 15:39:34.025269+00
5a9efa96-6e63-4f6f-ac83-ce86669b1f3c	3	\N	魔法学校の生徒リオ_128	8	12	visiting	\N	2025-06-13 15:39:34.026014+00	2025-06-13 18:39:34.026014+00	f	\N	\N	2025-06-13 15:39:34.025269+00	2025-06-13 15:39:34.025269+00
504723be-b0b8-48e2-a531-5d4be8151d23	3	\N	魔法学校の生徒リオ_515	4	5	visiting	\N	2025-06-13 15:39:44.828833+00	2025-06-13 16:59:44.828833+00	f	\N	\N	2025-06-13 15:39:44.827136+00	2025-06-13 15:39:44.827136+00
e1fcb4e1-f149-489e-aeb4-64100597c4f6	3	\N	魔法学校の生徒リオ_170	7	1	visiting	\N	2025-06-13 15:40:04.022184+00	2025-06-13 17:08:04.022184+00	f	\N	\N	2025-06-13 15:40:04.021198+00	2025-06-13 15:40:04.021198+00
c269d95c-4fcc-401c-b855-5d02d591e664	3	\N	魔法学校の生徒リオ_713	6	17	visiting	\N	2025-06-13 15:40:20.860338+00	2025-06-13 17:40:20.860338+00	f	\N	\N	2025-06-13 15:40:20.859561+00	2025-06-13 15:40:20.859561+00
93310e81-5e99-42d0-8569-f10685e91ec3	2	\N	見習い狩人サラ_329	10	15	visiting	\N	2025-06-13 15:40:20.860338+00	2025-06-13 16:51:20.860338+00	f	\N	\N	2025-06-13 15:40:20.859561+00	2025-06-13 15:40:20.859561+00
996f2279-fd97-4f87-97d3-3b1fbb4823d5	3	\N	魔法学校の生徒リオ_181	6	34	visiting	\N	2025-06-13 15:40:34.032214+00	2025-06-13 18:35:34.032214+00	f	\N	\N	2025-06-13 15:40:34.031363+00	2025-06-13 15:40:34.031363+00
96f24cce-04f1-4b09-8d28-881612181887	2	\N	見習い狩人サラ_136	7	24	visiting	\N	2025-06-13 15:41:04.101194+00	2025-06-13 18:32:04.101194+00	f	\N	\N	2025-06-13 15:41:04.100034+00	2025-06-13 15:41:04.100034+00
9737dd69-46dc-4cef-99be-78aa4c26b6e6	2	\N	見習い狩人サラ_291	10	8	visiting	\N	2025-06-13 15:41:04.101194+00	2025-06-13 16:28:04.101194+00	f	\N	\N	2025-06-13 15:41:04.100034+00	2025-06-13 15:41:04.100034+00
9257e774-0766-4a18-a7b4-43be81bf0cbe	2	\N	見習い狩人サラ_283	8	3	visiting	\N	2025-06-13 15:41:04.101194+00	2025-06-13 17:59:04.101194+00	f	\N	\N	2025-06-13 15:41:04.100034+00	2025-06-13 15:41:04.100034+00
a1b689c8-48d6-4e3a-b404-a2bb96635598	2	\N	見習い狩人サラ_638	10	16	visiting	\N	2025-06-13 15:41:26.90546+00	2025-06-13 17:02:26.90546+00	f	\N	\N	2025-06-13 15:41:26.903833+00	2025-06-13 15:41:26.903833+00
39389860-c117-47a8-961b-766f35398459	3	\N	魔法学校の生徒リオ_511	6	28	visiting	\N	2025-06-13 15:41:26.90546+00	2025-06-13 17:32:26.90546+00	f	\N	\N	2025-06-13 15:41:26.903833+00	2025-06-13 15:41:26.903833+00
630852e3-521c-4794-b8ac-665fb01c73e6	3	\N	魔法学校の生徒リオ_223	4	15	idle	\N	\N	\N	f	\N	\N	2025-06-13 14:54:11.060116+00	2025-06-13 15:41:33.931033+00
3fdaa29e-0e50-4c17-b05c-879eaa6951d2	2	\N	見習い狩人サラ_214	10	40	visiting	\N	2025-06-13 15:41:34.052399+00	2025-06-13 16:46:34.052399+00	f	\N	\N	2025-06-13 15:41:34.05105+00	2025-06-13 15:41:34.05105+00
3729fae9-322a-4cfa-8ed4-81ee4bbc51f4	3	\N	魔法学校の生徒リオ_733	7	23	visiting	\N	2025-06-13 15:42:04.36042+00	2025-06-13 18:33:04.36042+00	f	\N	\N	2025-06-13 15:42:04.35868+00	2025-06-13 15:42:04.35868+00
f76e834a-72c1-4432-a971-cfb30df022ae	2	\N	見習い狩人サラ_862	7	24	visiting	\N	2025-06-13 15:42:04.36042+00	2025-06-13 17:35:04.36042+00	f	\N	\N	2025-06-13 15:42:04.35868+00	2025-06-13 15:42:04.35868+00
6a98fd87-9a59-4710-ac94-9fa333faf65d	2	\N	見習い狩人サラ_795	9	36	visiting	\N	2025-06-13 15:42:04.36042+00	2025-06-13 18:38:04.36042+00	f	\N	\N	2025-06-13 15:42:04.35868+00	2025-06-13 15:42:04.35868+00
e8aa2414-200c-46a1-a190-860e15e9957a	2	\N	見習い狩人サラ_544	10	44	visiting	\N	2025-06-13 15:42:34.113475+00	2025-06-13 18:12:34.113475+00	f	\N	\N	2025-06-13 15:42:34.111675+00	2025-06-13 15:42:34.111675+00
713a3773-c802-4ddd-961f-0920d5e26b58	3	\N	魔法学校の生徒リオ_499	4	18	visiting	\N	2025-06-13 15:42:45.942255+00	2025-06-13 17:53:45.942255+00	f	\N	\N	2025-06-13 15:42:45.94097+00	2025-06-13 15:42:45.94097+00
64091b7e-5a10-4ddb-baac-ace1075cb28c	3	\N	魔法学校の生徒リオ_932	8	37	visiting	\N	2025-06-13 15:42:45.942255+00	2025-06-13 16:53:45.942255+00	f	\N	\N	2025-06-13 15:42:45.94097+00	2025-06-13 15:42:45.94097+00
301e8ec1-c736-4bc2-83d4-59d3f535c9e9	3	\N	魔法学校の生徒リオ_831	6	38	visiting	\N	2025-06-13 15:42:45.942255+00	2025-06-13 17:02:45.942255+00	f	\N	\N	2025-06-13 15:42:45.94097+00	2025-06-13 15:42:45.94097+00
ab9ff744-6358-4317-8bb2-ee5c243eee33	2	\N	見習い狩人サラ_595	8	43	visiting	\N	2025-06-13 15:43:04.072536+00	2025-06-13 17:27:04.072536+00	f	\N	\N	2025-06-13 15:43:04.071416+00	2025-06-13 15:43:04.071416+00
bba23de3-4cdf-4895-80c8-b4546cfe6df4	3	\N	魔法学校の生徒リオ_933	4	10	visiting	\N	2025-06-13 15:43:04.072536+00	2025-06-13 17:49:04.072536+00	f	\N	\N	2025-06-13 15:43:04.071416+00	2025-06-13 15:43:04.071416+00
a6db3b6e-36d6-4fec-be9d-654afa06c82c	2	\N	見習い狩人サラ_109	7	20	visiting	\N	2025-06-13 15:43:15.983097+00	2025-06-13 17:15:15.983097+00	f	\N	\N	2025-06-13 15:43:15.981961+00	2025-06-13 15:43:15.981961+00
ae3b1bf7-671f-441b-82b0-91301ec6b187	2	\N	見習い狩人サラ_46	10	17	visiting	\N	2025-06-13 15:43:15.983097+00	2025-06-13 16:29:15.983097+00	f	\N	\N	2025-06-13 15:43:15.981961+00	2025-06-13 15:43:15.981961+00
ff6e7d07-79c3-4bf2-ac52-67804a051d53	3	\N	魔法学校の生徒リオ_267	6	38	visiting	\N	2025-06-13 15:43:15.983097+00	2025-06-13 17:02:15.983097+00	f	\N	\N	2025-06-13 15:43:15.981961+00	2025-06-13 15:43:15.981961+00
fbfaad49-11da-4219-a4b4-6975e725e440	3	\N	魔法学校の生徒リオ_306	7	28	visiting	\N	2025-06-13 15:43:34.099266+00	2025-06-13 18:12:34.099266+00	f	\N	\N	2025-06-13 15:43:34.097824+00	2025-06-13 15:43:34.097824+00
71ec2674-d1fd-449d-aca8-5fced2b455bb	2	\N	見習い狩人サラ_885	7	48	visiting	\N	2025-06-13 15:43:34.099266+00	2025-06-13 17:58:34.099266+00	f	\N	\N	2025-06-13 15:43:34.097824+00	2025-06-13 15:43:34.097824+00
e03cee68-3b5d-44c8-8861-50a577b35a72	3	\N	魔法学校の生徒リオ_169	5	23	visiting	\N	2025-06-13 15:44:04.074763+00	2025-06-13 18:04:04.074763+00	f	\N	\N	2025-06-13 15:44:04.07339+00	2025-06-13 15:44:04.07339+00
30aa4980-9582-4a46-a76a-a62b710c6ee8	3	\N	魔法学校の生徒リオ_19	6	43	visiting	\N	2025-06-13 15:44:34.017377+00	2025-06-13 18:07:34.017377+00	f	\N	\N	2025-06-13 15:44:34.016074+00	2025-06-13 15:44:34.016074+00
0c032672-154f-4b6b-aef1-107ce35ca087	3	\N	魔法学校の生徒リオ_138	6	10	visiting	\N	2025-06-13 15:44:58.056719+00	2025-06-13 17:34:58.056719+00	f	\N	\N	2025-06-13 15:44:58.05523+00	2025-06-13 15:44:58.05523+00
a2cca07e-7d98-4c4c-a188-d993b9d60759	3	\N	魔法学校の生徒リオ_921	8	37	visiting	\N	2025-06-13 15:44:58.056719+00	2025-06-13 17:22:58.056719+00	f	\N	\N	2025-06-13 15:44:58.05523+00	2025-06-13 15:44:58.05523+00
54ad1bf0-5097-4727-8fcc-cb72546d7e4b	3	\N	魔法学校の生徒リオ_171	7	34	visiting	\N	2025-06-13 15:45:04.138634+00	2025-06-13 18:06:04.138634+00	f	\N	\N	2025-06-13 15:45:04.137689+00	2025-06-13 15:45:04.137689+00
bb0c8af5-2013-4bb6-a82a-4c50f16c08cc	3	\N	魔法学校の生徒リオ_936	7	48	visiting	\N	2025-06-13 15:45:34.11141+00	2025-06-13 17:08:34.11141+00	f	\N	\N	2025-06-13 15:45:34.109703+00	2025-06-13 15:45:34.109703+00
82d74c60-eacc-453a-994c-9278be44b19a	2	\N	見習い狩人サラ_469	9	37	visiting	\N	2025-06-13 15:45:34.11141+00	2025-06-13 16:46:34.11141+00	f	\N	\N	2025-06-13 15:45:34.109703+00	2025-06-13 15:45:34.109703+00
30a6ca1f-541c-45b0-931c-a100c30f9e09	2	\N	見習い狩人サラ_680	9	8	visiting	\N	2025-06-13 15:46:04.008755+00	2025-06-13 16:31:04.008755+00	f	\N	\N	2025-06-13 15:46:04.007906+00	2025-06-13 15:46:04.007906+00
59d302a9-f2bf-40f8-a8cf-f06c93c6084d	3	\N	魔法学校の生徒リオ_724	5	33	visiting	\N	2025-06-13 15:46:04.008755+00	2025-06-13 17:35:04.008755+00	f	\N	\N	2025-06-13 15:46:04.007906+00	2025-06-13 15:46:04.007906+00
1bb29d29-fa12-4fbe-9db2-e4b7da327417	2	\N	見習い狩人サラ_751	6	26	visiting	\N	2025-06-13 15:46:05.100213+00	2025-06-13 16:58:05.100213+00	f	\N	\N	2025-06-13 15:46:05.099158+00	2025-06-13 15:46:05.099158+00
1f479029-9d25-4af8-b3cd-cf9e2f8c7670	2	\N	見習い狩人サラ_496	10	4	visiting	\N	2025-06-13 15:46:05.100213+00	2025-06-13 18:25:05.100213+00	f	\N	\N	2025-06-13 15:46:05.099158+00	2025-06-13 15:46:05.099158+00
e92cf4fd-b964-42c5-b16a-10603d9a7b0c	3	\N	魔法学校の生徒リオ_940	6	27	visiting	\N	2025-06-13 15:46:34.216892+00	2025-06-13 16:48:34.216892+00	f	\N	\N	2025-06-13 15:46:34.215708+00	2025-06-13 15:46:34.215708+00
\.


--
-- Data for Name: adventurer_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_masters (id, name, class, level_min, level_max, preferred_weapon_types, budget_min, budget_max, personality, haggle_skill, trust_base, avatar_image, description, spawn_rate, visit_frequency_hours, is_active, created_at, profession, level, trust_level, preferred_weapon_type, avatar_url, min_attack_requirement, max_budget_multiplier, urgency_tendency, spawn_weight, min_player_level, max_player_level, tier, progression_multiplier, updated_at) FROM stdin;
1	村の少年タム	warrior	1	100	\N	50	200	friendly	50	50	\N	村で冒険を始めたばかりの少年	0.1000	4	t	2025-06-13 00:25:23.256017+00	warrior	5	10	sword	\N	10	1.0	1	100	1	3	normal	1.0	2025-06-13 00:25:23.256017+00
2	見習い狩人サラ	archer	1	100	\N	80	300	normal	50	50	\N	弓の練習をしている見習い	0.1000	4	t	2025-06-13 00:25:23.256017+00	archer	8	15	bow	\N	20	1.2	2	80	1	5	normal	1.0	2025-06-13 00:25:23.256017+00
3	魔法学校の生徒リオ	mage	1	100	\N	60	250	stingy	50	50	\N	魔法学校の1年生	0.1000	4	t	2025-06-13 00:25:23.256017+00	mage	6	20	staff	\N	15	0.8	1	60	1	4	normal	1.0	2025-06-13 00:25:23.256017+00
warrior_rick	戦士リック	warrior	1	30	{sword}	500	3000	cautious	60	50	\N	慎重な性格の若い戦士	0.2000	4	f	2025-06-11 22:48:29.945623+00	warrior	15	50	\N	\N	100	1.0	3	100	1	\N	normal	1.0	2025-06-13 00:24:18.124149+00
archer_anna	弓使いアンナ	archer	1	25	{bow}	400	2500	bold	70	55	\N	大胆で活発な弓使い	0.2000	5	f	2025-06-11 22:48:29.945623+00	archer	13	50	\N	\N	100	1.0	3	100	1	\N	normal	1.0	2025-06-13 00:24:18.124149+00
mage_elena	魔法使いエリナ	mage	1	35	{staff}	600	4000	generous	40	60	\N	寛大で知的な魔法使い	0.1500	6	f	2025-06-11 22:48:29.945623+00	mage	18	50	\N	\N	100	1.0	3	100	1	\N	normal	1.0	2025-06-13 00:24:18.124149+00
rogue_jack	盗賊ジャック	rogue	5	20	{sword,bow}	300	2000	cheap	85	40	\N	ケチで狡猾な盗賊	0.2500	3	f	2025-06-11 22:48:29.945623+00	rogue	12	50	\N	\N	100	1.0	3	100	1	\N	normal	1.0	2025-06-13 00:24:18.124149+00
paladin_marcus	聖騎士マーカス	paladin	10	40	{sword}	1000	6000	generous	50	70	\N	正義感の強い聖騎士	0.1000	8	f	2025-06-11 22:48:29.945623+00	paladin	25	50	\N	\N	100	1.0	3	100	1	\N	normal	1.0	2025-06-13 00:24:18.124149+00
\.


--
-- Data for Name: adventurer_purchases; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_purchases (id, adventurer_instance_id, weapon_id, purchase_price, negotiated_price, satisfaction_score, purchased_at) FROM stdin;
8e37a8c0-e6fe-4a6e-ac0f-9145010c1103	25a6533e-f3f3-4e38-b10f-355af8257d79	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 05:42:59.663586+00
40cfe58a-17e1-4e31-9b8d-52352457dc79	83dc02f4-d469-4085-acf0-022929858bd5	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 05:43:15.102804+00
44039728-7f94-481b-92e3-ae769ede48e1	05b537cd-3839-48df-a071-33b6c8552f49	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 07:21:20.122344+00
8568bf4e-1d33-463e-9883-d7e391359867	c0564312-8670-45b4-99bd-072eaf075765	b7dbf1c3-fdd9-4cb8-8686-246058386036	18	\N	0.5	2025-06-13 07:21:35.659994+00
ce91ac56-f365-4e2c-ad09-675f96becf31	f66631c7-7a6b-4da3-9186-601a9aac9369	21799ee9-dcbf-435a-ba16-b399b00c3483	25	\N	0.5	2025-06-13 07:27:50.786903+00
ebd1c134-2b80-48fa-825a-09f3f47450e4	e21bcebc-8ad8-4fff-8091-5638d0ced3eb	21799ee9-dcbf-435a-ba16-b399b00c3483	25	\N	0.5	2025-06-13 07:35:16.391726+00
e3bdf6cf-2d2b-478b-8325-72eda45d35a8	97dacd96-aedb-4a90-9f38-4c725f65fd49	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 07:41:05.923879+00
6aaa9fc8-a274-4033-a2db-e0f329d87352	15f48f82-4f6c-4d82-8767-7d4efb2d42c9	29915dce-385e-47b7-a457-1488b98f0e80	160	\N	0.5	2025-06-13 07:42:01.434521+00
f6e913b3-4d26-4ab0-8d71-4d579172228a	35da8604-6a61-4164-9408-4a2868cdb0a4	b7dbf1c3-fdd9-4cb8-8686-246058386036	18	\N	0.5	2025-06-13 07:42:32.157129+00
66e7b6e2-42bb-487c-9ede-02dd0031788e	c4fb8966-cb4f-49c8-9eb7-80e03c6ec3ad	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 07:42:50.781333+00
048cb473-8676-4294-9e25-705ae45827e3	f728110b-7d25-4d7f-9cc7-c59f122edf45	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 07:46:30.076446+00
52d230a0-703d-448b-95ea-73d7f49f44fd	916a01b9-6dc0-403a-ac16-47fee3046686	21799ee9-dcbf-435a-ba16-b399b00c3483	25	\N	0.5	2025-06-13 07:48:22.640162+00
13982cda-94cf-4af2-ad27-3a05645ca0a2	9ab2ff7d-f79a-4e5a-a98c-f778f7380862	7aa4f203-fc18-4cef-8263-6ad6acde1b02	200	\N	0.5	2025-06-13 08:16:45.186145+00
8f7ff9a5-2b33-489c-9203-f0d33d969dfd	ac499199-ec34-4b1b-91b9-1481d4a117c6	b7dbf1c3-fdd9-4cb8-8686-246058386036	18	\N	0.5	2025-06-13 08:18:27.08783+00
86e2bda6-dec0-4284-8a4a-cadce4778d6e	520ce486-f4d5-48c5-a66e-f9dbe73d820c	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 08:18:53.109846+00
e3998508-0601-40f0-ad78-2849e964a0b7	b0ec7fbe-c8be-488c-b790-36017e75ff2b	407a40f0-4a74-4669-82b5-37851a9c9229	28	\N	0.5	2025-06-13 08:19:11.053214+00
98470255-09d7-439f-91a5-97f6575ff28c	2064b96b-2d62-4eb8-9231-295143bf4f84	4db8757f-ef96-42be-95c3-0f0f535d8970	200	\N	0.5	2025-06-13 08:19:47.615899+00
0e86b142-fde8-4ee1-9e48-79036a9b64c9	d4b7b184-c132-4b33-82e0-34cdafb9cc3a	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 08:25:58.596212+00
87fc7c9f-5793-4288-ac5a-c3e4423f88da	8b247dae-8d98-4142-8cbf-147bef461785	e83549ad-27c5-4fbe-8a95-2bec8a3f7726	80	\N	0.5	2025-06-13 08:32:48.74353+00
f875c2ff-a4b5-4bdb-baf3-d13bce01dda4	9250a22d-3668-4b83-99c0-1a94cf713bee	e83549ad-27c5-4fbe-8a95-2bec8a3f7726	80	\N	0.5	2025-06-13 09:18:37.774607+00
394b0eec-37f6-48a6-ab86-1be141ba48da	d6185d55-4be1-469d-b458-5d06915fa539	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 09:19:07.085079+00
d7435116-fcda-4cc6-b22f-7818195405b3	035a6fef-87ab-4e2c-aafb-dc1bbd079df6	407a40f0-4a74-4669-82b5-37851a9c9229	28	\N	0.5	2025-06-13 09:19:49.726863+00
de2a025c-5787-4a12-a980-23ab3db4ecdb	27957315-4650-4449-be63-012bd7575878	b7dbf1c3-fdd9-4cb8-8686-246058386036	18	\N	0.5	2025-06-13 09:20:46.539353+00
fe5446b1-4445-478a-8c78-72af300972d5	cee2745a-25db-4eeb-8e78-5fd8371b421c	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 09:24:23.507613+00
bd4d841f-ecb8-4feb-af29-6e464913a32c	e37d6870-9031-4c20-9e1d-7c3cb0efc6bf	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	90	\N	0.5	2025-06-13 09:26:57.945411+00
966c11e3-82a3-40c4-803a-582e699cea8a	ef4e2721-37a0-4102-9bfe-322a845babe8	4db8757f-ef96-42be-95c3-0f0f535d8970	200	\N	0.5	2025-06-13 12:27:37.393209+00
96de76e8-30d1-4c23-80e7-355158601d4f	2bd33839-9d42-48e7-9289-84a76f505c34	f41b6862-a855-4060-a943-4a33f6be3841	15	\N	0.5	2025-06-13 12:33:22.869719+00
ded32f58-ded9-4d48-8049-d4af0795f271	1fd172c5-68f1-4b7d-9bb1-19f25c4e33c4	21799ee9-dcbf-435a-ba16-b399b00c3483	25	\N	0.5	2025-06-13 12:39:17.34985+00
96c04b18-1949-4c56-baca-1a759f304dc4	408324c3-3986-4a1e-a243-1fa68894c5bb	407a40f0-4a74-4669-82b5-37851a9c9229	28	\N	0.5	2025-06-13 12:39:34.001126+00
\.


--
-- Data for Name: adventurer_quests; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_quests (id, adventurer_instance_id, quest_area_id, player_weapon_id, monster_id, target_material_id, target_material_boost, target_cost, status, start_time, end_time, success, gold_earned, created_at, updated_at) FROM stdin;
1ae264d9-b86a-43a5-83ec-25a755640387	d9641fe5-37c9-4ea2-9be9-6b90486de09d	17	\N	spirit_tree	\N	1	0	completed	2025-06-13 05:43:08.783437+00	2025-06-13 06:13:08.783445+00	\N	0	2025-06-13 05:43:08.750188+00	2025-06-13 08:57:24.420423+00
647f5876-aa8d-4b47-8b45-d864b27d4e29	25a6533e-f3f3-4e38-b10f-355af8257d79	18	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	mushroom_poison	\N	1	0	completed	2025-06-13 05:42:59.699027+00	2025-06-13 06:27:59.699031+00	\N	0	2025-06-13 05:42:59.691492+00	2025-06-13 08:57:24.541487+00
5711d13c-cbf2-4789-93e5-c052c0525444	83dc02f4-d469-4085-acf0-022929858bd5	20	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	rat_cave	\N	1	0	completed	2025-06-13 05:43:15.118393+00	2025-06-13 06:58:15.118396+00	\N	0	2025-06-13 05:43:15.113841+00	2025-06-13 08:57:24.585394+00
38b3a05e-c463-4e30-abe5-3d77db831c07	05b537cd-3839-48df-a071-33b6c8552f49	20	f41b6862-a855-4060-a943-4a33f6be3841	treeling	\N	1	0	completed	2025-06-13 07:21:20.171866+00	2025-06-13 08:36:20.171869+00	\N	0	2025-06-13 07:21:20.159725+00	2025-06-13 08:57:24.628389+00
b9ceadbe-2a42-4a84-be7f-a254f3ba85e8	c0564312-8670-45b4-99bd-072eaf075765	18	b7dbf1c3-fdd9-4cb8-8686-246058386036	mushroom_poison	\N	1	0	completed	2025-06-13 07:21:35.689314+00	2025-06-13 08:06:35.689319+00	\N	0	2025-06-13 07:21:35.681219+00	2025-06-13 08:57:24.669222+00
a6a27118-b623-443e-a4a4-525edfb97a8d	2064b96b-2d62-4eb8-9231-295143bf4f84	17	4db8757f-ef96-42be-95c3-0f0f535d8970	spider_forest	\N	1	0	completed	2025-06-13 08:19:47.63442+00	2025-06-13 08:49:47.634424+00	\N	0	2025-06-13 08:19:47.628893+00	2025-06-13 08:57:24.688932+00
a5702bce-0a8a-4286-acb2-32cd55a1cd1d	e21bcebc-8ad8-4fff-8091-5638d0ced3eb	17	21799ee9-dcbf-435a-ba16-b399b00c3483	spirit_tree	\N	1	0	completed	2025-06-13 07:35:16.431992+00	2025-06-13 08:05:16.431995+00	\N	0	2025-06-13 07:35:16.424949+00	2025-06-13 08:57:24.711588+00
88c1436c-a08e-4485-be44-757c3575e21e	97dacd96-aedb-4a90-9f38-4c725f65fd49	19	f41b6862-a855-4060-a943-4a33f6be3841	ent_young	\N	1	0	completed	2025-06-13 07:41:05.946541+00	2025-06-13 08:41:05.946545+00	\N	0	2025-06-13 07:41:05.938877+00	2025-06-13 08:57:24.767652+00
1e6d7958-bf2e-494f-b101-1bb97d2aa561	15f48f82-4f6c-4d82-8767-7d4efb2d42c9	18	29915dce-385e-47b7-a457-1488b98f0e80	snake_grass	\N	1	0	completed	2025-06-13 07:42:01.454461+00	2025-06-13 08:27:01.454464+00	\N	0	2025-06-13 07:42:01.446428+00	2025-06-13 08:57:24.792182+00
9040306c-588a-4e0e-9c22-733af6ccf27b	916a01b9-6dc0-403a-ac16-47fee3046686	18	21799ee9-dcbf-435a-ba16-b399b00c3483	sprite_water	\N	1	0	completed	2025-06-13 07:48:22.659823+00	2025-06-13 08:33:22.659826+00	\N	0	2025-06-13 07:48:22.651872+00	2025-06-13 08:57:24.810807+00
390313b7-38a0-4614-b929-6689607df383	f66631c7-7a6b-4da3-9186-601a9aac9369	18	21799ee9-dcbf-435a-ba16-b399b00c3483	snake_grass	\N	1	0	completed	2025-06-13 07:27:50.808887+00	2025-06-13 08:12:50.808891+00	\N	0	2025-06-13 07:27:50.802249+00	2025-06-13 08:57:24.833797+00
492984d3-597b-472e-80a6-447c7dd7b733	35da8604-6a61-4164-9408-4a2868cdb0a4	20	b7dbf1c3-fdd9-4cb8-8686-246058386036	slime_metal	\N	1	0	completed	2025-06-13 07:42:32.181755+00	2025-06-13 08:57:32.181758+00	\N	0	2025-06-13 07:42:32.175964+00	2025-06-13 08:58:17.244505+00
eafeee04-b121-4d3e-994c-a92427c38af1	c4fb8966-cb4f-49c8-9eb7-80e03c6ec3ad	20	f41b6862-a855-4060-a943-4a33f6be3841	bat_swarm	\N	1	0	completed	2025-06-13 07:42:50.797423+00	2025-06-13 08:57:50.797426+00	\N	0	2025-06-13 07:42:50.79307+00	2025-06-13 08:58:17.36292+00
16a8823a-b52a-4f1f-a978-ea16353f9152	f728110b-7d25-4d7f-9cc7-c59f122edf45	20	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	golem_copper	\N	1	0	completed	2025-06-13 07:46:30.107319+00	2025-06-13 09:01:30.107323+00	\N	0	2025-06-13 07:46:30.100023+00	2025-06-13 09:01:41.124492+00
a1ccb729-9ecc-4677-9d97-5a79d67411b1	8b247dae-8d98-4142-8cbf-147bef461785	17	e83549ad-27c5-4fbe-8a95-2bec8a3f7726	bee_giant	\N	1	0	completed	2025-06-13 08:32:48.774138+00	2025-06-13 09:02:48.774142+00	\N	0	2025-06-13 08:32:48.767427+00	2025-06-13 09:03:11.101164+00
f314502e-c689-4c3e-95fd-186901b7aecf	ac499199-ec34-4b1b-91b9-1481d4a117c6	18	b7dbf1c3-fdd9-4cb8-8686-246058386036	mushroom_poison	\N	1	0	completed	2025-06-13 08:18:27.108301+00	2025-06-13 09:03:27.108304+00	\N	0	2025-06-13 08:18:27.102548+00	2025-06-13 09:03:41.242753+00
cd364b6e-387e-42fd-8483-e8339d179c5b	520ce486-f4d5-48c5-a66e-f9dbe73d820c	18	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	slime_blue	\N	1	0	completed	2025-06-13 08:18:53.125386+00	2025-06-13 09:03:53.125394+00	\N	0	2025-06-13 08:18:53.12023+00	2025-06-13 09:04:11.005259+00
be6c8f5a-34af-4aa8-a135-e446f3150196	b0ec7fbe-c8be-488c-b790-36017e75ff2b	18	407a40f0-4a74-4669-82b5-37851a9c9229	sprite_water	\N	1	0	completed	2025-06-13 08:19:11.070322+00	2025-06-13 09:04:11.070325+00	\N	0	2025-06-13 08:19:11.063975+00	2025-06-13 09:04:41.11837+00
b9e08a70-35f3-4cff-9f5d-ece9cffdb8ed	d4b7b184-c132-4b33-82e0-34cdafb9cc3a	18	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	stag_giant	\N	1	0	completed	2025-06-13 08:25:58.613511+00	2025-06-13 09:10:58.613514+00	\N	0	2025-06-13 08:25:58.609046+00	2025-06-13 09:11:11.069914+00
318dacbc-1438-4cd5-81d2-f4b319bc596f	9ab2ff7d-f79a-4e5a-a98c-f778f7380862	17	7aa4f203-fc18-4cef-8263-6ad6acde1b02	spirit_tree	\N	1	0	completed	2025-06-13 08:16:45.217563+00	2025-06-13 08:46:45.217566+00	\N	0	2025-06-13 08:16:45.210064+00	2025-06-13 09:33:49.558575+00
d2f693ba-cc52-42e3-a65a-c1e2fa2f6efe	9250a22d-3668-4b83-99c0-1a94cf713bee	18	e83549ad-27c5-4fbe-8a95-2bec8a3f7726	boar_wild	\N	1	0	completed	2025-06-13 09:18:37.809619+00	2025-06-13 10:03:37.809624+00	\N	0	2025-06-13 09:18:37.800978+00	2025-06-13 12:27:14.482426+00
bbd22738-1de1-42b5-9cb5-c42bb6d49d70	035a6fef-87ab-4e2c-aafb-dc1bbd079df6	17	407a40f0-4a74-4669-82b5-37851a9c9229	slime_green	\N	1	0	completed	2025-06-13 09:19:49.741579+00	2025-06-13 09:49:49.741583+00	\N	0	2025-06-13 09:19:49.736603+00	2025-06-13 12:27:14.743793+00
76d3a379-3656-44a2-8115-1a1941b421b3	d6185d55-4be1-469d-b458-5d06915fa539	19	f41b6862-a855-4060-a943-4a33f6be3841	ghost_miner	\N	1	0	completed	2025-06-13 09:19:07.102895+00	2025-06-13 10:19:07.102898+00	\N	0	2025-06-13 09:19:07.098117+00	2025-06-13 12:27:14.824158+00
ce52ca92-abf7-4c3f-b686-e236850fdace	cee2745a-25db-4eeb-8e78-5fd8371b421c	19	f41b6862-a855-4060-a943-4a33f6be3841	golem_copper	\N	1	0	completed	2025-06-13 09:24:23.52273+00	2025-06-13 10:24:23.522733+00	\N	0	2025-06-13 09:24:23.517675+00	2025-06-13 12:27:14.891278+00
c15c28f2-4932-4b3c-bb90-8751b83ded0d	27957315-4650-4449-be63-012bd7575878	17	b7dbf1c3-fdd9-4cb8-8686-246058386036	pixie_mischief	\N	1	0	completed	2025-06-13 09:20:46.552131+00	2025-06-13 09:50:46.552133+00	\N	0	2025-06-13 09:20:46.548067+00	2025-06-13 12:27:14.972797+00
6fb3c717-e08e-41f8-9486-cf3f290e0357	e37d6870-9031-4c20-9e1d-7c3cb0efc6bf	19	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	bear_forest	\N	1	0	completed	2025-06-13 09:26:57.966759+00	2025-06-13 10:26:57.966762+00	\N	0	2025-06-13 09:26:57.961094+00	2025-06-13 12:27:15.056475+00
a9a2a054-67dc-4ccb-84f5-8299dd0a0db3	ef4e2721-37a0-4102-9bfe-322a845babe8	17	4db8757f-ef96-42be-95c3-0f0f535d8970	spider_forest	\N	1	0	completed	2025-06-13 12:27:37.443056+00	2025-06-13 12:57:37.44306+00	\N	0	2025-06-13 12:27:37.435148+00	2025-06-13 12:57:45.304703+00
47748578-579a-4b1e-a079-4ee4aa1379b1	1fd172c5-68f1-4b7d-9bb1-19f25c4e33c4	17	21799ee9-dcbf-435a-ba16-b399b00c3483	spider_forest	\N	1	0	completed	2025-06-13 12:39:17.472378+00	2025-06-13 13:09:17.472382+00	\N	0	2025-06-13 12:39:17.456866+00	2025-06-13 13:09:45.304807+00
b749852b-2a84-4f88-b19d-d912215bb81d	408324c3-3986-4a1e-a243-1fa68894c5bb	18	407a40f0-4a74-4669-82b5-37851a9c9229	sprite_water	\N	1	0	completed	2025-06-13 12:39:34.022475+00	2025-06-13 13:24:34.022477+00	\N	0	2025-06-13 12:39:34.013252+00	2025-06-13 13:24:47.353588+00
11ae9b72-a595-45dc-967f-fe86ac2893d0	2bd33839-9d42-48e7-9289-84a76f505c34	20	f41b6862-a855-4060-a943-4a33f6be3841	wolf_forest	\N	1	0	completed	2025-06-13 12:33:22.902782+00	2025-06-13 13:48:22.902786+00	\N	0	2025-06-13 12:33:22.896725+00	2025-06-13 13:48:26.337039+00
\.


--
-- Data for Name: adventurer_requests; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_requests (id, adventurer_instance_id, weapon_type_id, rarity_level_id, budget_min, budget_max, priority_score, urgency_level, special_requirements, status, created_at, fulfilled_at, weapon_id, weapon_type, min_attack, max_budget, preferred_rarity, urgency, description, deadline, updated_at) FROM stdin;
e7a31a5e-011d-41f5-834b-7d282bb5fd1d	e844bcdf-afa5-4a1c-a7b1-b36bd23d0e0f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 00:30:56.357167+00	\N	\N	sword	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:30:56.358987+00	2025-06-13 00:30:56.357167+00
c91925cc-316a-4b4c-ae85-43115c6890bf	1ec7f7ff-e6b1-4880-ba2a-645e2b02041b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 01:32:39.434959+00	\N	\N	hammer	3	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:32:39.574558+00	2025-06-13 01:32:39.434959+00
b975cec7-e8c1-4d7a-9c55-8184fc2eea55	79fd2cd5-da09-4528-803c-a1109d4e3655	\N	\N	0	0	1	normal	\N	pending	2025-06-13 02:02:09.550514+00	\N	\N	hammer	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 05:02:09.551539+00	2025-06-13 02:02:09.550514+00
cea2c237-4e63-4857-a675-d3efe4cb9b56	3744e847-3d57-4bc1-9ccd-6871ac0561cc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 02:02:09.550514+00	\N	\N	staff	18	157	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 20:02:09.551539+00	2025-06-13 02:02:09.550514+00
010d6d64-e134-4d7d-9308-6144593587a7	36fbac44-3cbb-4b18-bedb-dbeaf1b3470b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 02:02:09.550514+00	\N	\N	sword	5	66	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 06:02:09.551539+00	2025-06-13 02:02:09.550514+00
9bf3690d-f3fe-467d-9a10-48e593396e71	05a213e3-8dd5-4e10-a134-37c58f9ef130	\N	\N	0	0	1	normal	\N	pending	2025-06-13 02:44:51.419113+00	\N	\N	sword	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:44:51.420257+00	2025-06-13 02:44:51.419113+00
3a712b03-7e3d-416f-87f8-7c7490b2d967	25a6533e-f3f3-4e38-b10f-355af8257d79	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:08:20.962539+00	\N	\N	bow	6	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:08:20.963713+00	2025-06-13 03:08:20.962539+00
a1775926-1372-4f07-aaf6-55a382c24fc7	d9641fe5-37c9-4ea2-9be9-6b90486de09d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:08:20.962539+00	\N	\N	staff	4	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 10:08:20.963713+00	2025-06-13 03:08:20.962539+00
628cca76-2bea-4a5b-b9ce-8aa390f5d6f9	83dc02f4-d469-4085-acf0-022929858bd5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:08:20.962539+00	\N	\N	bow	3	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:08:20.963713+00	2025-06-13 03:08:20.962539+00
9795f18c-5593-4d65-b303-1263cbc5a762	2353f2ba-ea33-4636-93b1-cdc5c3c0df46	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:15:58.920082+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-13 19:15:58.921986+00	2025-06-13 03:15:58.920082+00
6b43904b-ac52-45ae-b730-9abfe2ff608a	b2088bbf-68f5-40aa-bbd3-cfae3b6ed53c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:15:58.920082+00	\N	\N	staff	3	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:15:58.921986+00	2025-06-13 03:15:58.920082+00
f83dcc5e-dbe4-4670-84de-348ce6c6f3bb	5cbdcaa5-9744-4063-9ada-86543ee58ad7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:15:58.920082+00	\N	\N	staff	6	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:15:58.921986+00	2025-06-13 03:15:58.920082+00
b8741d5f-3969-4080-946e-7121f1ed8fc4	b3993cb5-795b-43fd-90c6-f07c7b389463	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:17:08.265479+00	\N	\N	hammer	4	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:17:08.268447+00	2025-06-13 03:17:08.265479+00
ad11f86a-2e92-485f-b78d-aeb83924c28e	3b1f037a-6432-4345-a300-6972e052cbe6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:17:08.265479+00	\N	\N	bow	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:17:08.268447+00	2025-06-13 03:17:08.265479+00
ba431db4-6249-43cf-a230-e805ef81427b	a6751e6c-39fe-459d-9060-4d57e0dee549	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:31:23.053001+00	\N	\N	staff	3	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 14:31:23.054429+00	2025-06-13 03:31:23.053001+00
0fce2334-37f8-4c5c-944f-42bbad804790	93b69f65-7370-47c1-945d-e89d599982b0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:31:23.053001+00	\N	\N	bow	7	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:31:23.054429+00	2025-06-13 03:31:23.053001+00
6d44c5d3-5e2b-4f57-9124-9eef57180cfa	741e5ff6-e849-4716-8086-7cb9d5761c6c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:31:23.053001+00	\N	\N	staff	6	52	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 11:31:23.054429+00	2025-06-13 03:31:23.053001+00
ca220e26-95fd-40b8-a058-deab1105e686	c1621ced-01f2-4ef5-9fc4-0c814a86ea90	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:34:51.723429+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 09:34:51.724895+00	2025-06-13 03:34:51.723429+00
6e90e98b-0c7f-4506-81a3-ef3c3fdee54d	7fef9f17-5823-4243-9f79-89c483fb583c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:34:51.723429+00	\N	\N	bow	4	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:34:51.724895+00	2025-06-13 03:34:51.723429+00
a08d40e8-0584-481c-8883-ca2c9f8e77b5	0492cfbd-a3eb-4164-b665-85904a885310	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:35:42.040449+00	\N	\N	hammer	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 09:35:42.041612+00	2025-06-13 03:35:42.040449+00
fddc7edd-31e7-431e-97a7-f55a435afee1	51226919-9498-424e-94b7-314ec3c19c4a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:35:42.040449+00	\N	\N	sword	3	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:35:42.041612+00	2025-06-13 03:35:42.040449+00
30069dfa-16ad-4293-b3d8-fe92f7c8827f	494a85cc-0e2a-49a5-96c1-1171583a326a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:35:42.040449+00	\N	\N	bow	4	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:35:42.041612+00	2025-06-13 03:35:42.040449+00
017e398b-ebb3-4602-913a-24ef526501a4	114b0832-c04a-4712-9408-3765177c90f9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:53:59.228525+00	\N	\N	sword	6	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:53:59.229705+00	2025-06-13 03:53:59.228525+00
f857062d-da7b-4248-b6d8-d34e14e9bfab	f643fe4a-c860-4dde-aba5-548f4744d061	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:53:59.228525+00	\N	\N	dagger	4	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:53:59.229705+00	2025-06-13 03:53:59.228525+00
6afce2a3-fdb4-42c5-a801-24d83fc67aaa	e64d44c7-86cc-41a4-89d1-735969538cdb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:53:59.228525+00	\N	\N	dagger	7	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:53:59.229705+00	2025-06-13 03:53:59.228525+00
27d301ba-3231-4483-a9ef-1b51d566abb2	9b1ba7ce-0944-420e-aaea-f1552c8436a1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:55:46.667605+00	\N	\N	dagger	19	285	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:55:46.669008+00	2025-06-13 03:55:46.667605+00
cbab33c7-40e3-4b27-b145-135f9f639ba1	2fe606cc-d51b-4e2e-be20-1530e0b9ac17	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:55:46.667605+00	\N	\N	sword	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:55:46.669008+00	2025-06-13 03:55:46.667605+00
87851f45-ec72-4a86-b51e-77f84c2a9d8d	dcb65b43-b531-4244-886f-9d4ee1966b86	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:56:06.440035+00	\N	\N	dagger	7	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:56:06.441334+00	2025-06-13 03:56:06.440035+00
75922f1a-3a65-4c1e-961c-b1ce749f436a	3d115f7d-b569-413e-9216-f70e32301e04	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:56:06.440035+00	\N	\N	hammer	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:56:06.441334+00	2025-06-13 03:56:06.440035+00
62e03698-c888-4392-b493-bd8cf6cfab08	f72b533b-ddb2-4326-b3bc-c77d008e2635	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:56:06.440035+00	\N	\N	sword	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:56:06.441334+00	2025-06-13 03:56:06.440035+00
d5ef990e-287b-40c4-9aee-6cc63a4e9c5d	d88c2cab-f1ba-475d-bfcf-a127e197f358	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:56:06.440035+00	\N	\N	sword	16	176	epic	2	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 22:56:06.441334+00	2025-06-13 03:56:06.440035+00
cbd4505d-1698-4274-b676-99738ca04527	9d893a81-8924-4c45-9b84-05dea1acd72b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 03:56:06.440035+00	\N	\N	hammer	4	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 06:56:06.441334+00	2025-06-13 03:56:06.440035+00
c3c19432-fde3-4602-8fba-987f3f22ecd2	487116cf-7730-4537-b5e2-2ae5c19ace10	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:03:14.279199+00	\N	\N	hammer	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 09:03:14.280987+00	2025-06-13 04:03:14.279199+00
bd4bab4b-77a1-48a9-bcd2-dab2c75eb065	b7d56235-43cf-4065-96f6-e7687e627e9a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:03:14.279199+00	\N	\N	staff	4	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 13:03:14.280987+00	2025-06-13 04:03:14.279199+00
b61c2d9c-7dde-47a8-993e-6ead014ca474	b35d51b7-1cbb-4878-b288-7bb7a7749f5b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:13:59.074289+00	\N	\N	bow	14	210	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:13:59.076016+00	2025-06-13 04:13:59.074289+00
b539106c-a722-443d-bd80-05f64032cbf8	61adb853-0294-46ed-86aa-a0220af308b0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:13:59.074289+00	\N	\N	sword	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:13:59.076016+00	2025-06-13 04:13:59.074289+00
5ad9c342-6eb8-4926-8048-4164f325459d	f32796e1-b9d1-4e34-b0bc-7932f92e86f2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:13:59.074289+00	\N	\N	staff	20	175	common	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 14:13:59.076016+00	2025-06-13 04:13:59.074289+00
2fd74b9d-8bf1-40cb-a69f-13fe5f37e9db	267773c8-ff9b-4cbd-8ba1-caf53936264b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:08.531406+00	\N	\N	staff	4	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 12:23:08.533922+00	2025-06-13 04:23:08.531406+00
1162ae30-5c2a-4f2e-8be3-2352fa2c27de	aeb5e649-af34-4285-9b41-b72697de19fe	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:08.531406+00	\N	\N	dagger	4	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:23:08.533922+00	2025-06-13 04:23:08.531406+00
8bf09dfc-cefa-4b64-ae73-bd51e32dd93e	2dbf16ed-1fc1-4f30-bbc5-318041eacbc8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:08.531406+00	\N	\N	hammer	18	198	epic	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 14:23:08.533922+00	2025-06-13 04:23:08.531406+00
ce2cd198-b2b3-4221-a591-1a994b8dc5da	7d454b2f-af60-4f05-b25f-3434b061ce85	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:08.531406+00	\N	\N	staff	6	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 11:23:08.533922+00	2025-06-13 04:23:08.531406+00
06fe7c3c-8d64-48b3-9d63-b0133f83ad83	3697ecd9-0b3a-4376-bcbe-0289a5e37a58	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:37.188158+00	\N	\N	bow	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:23:37.189625+00	2025-06-13 04:23:37.188158+00
646dfbdd-2194-42cc-ad28-21f8e66f9134	9b935d66-54fd-4465-8e6f-fd74bd725545	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:37.188158+00	\N	\N	bow	6	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:23:37.189625+00	2025-06-13 04:23:37.188158+00
7464cce8-38b1-447b-9a91-ab97b876e30e	05b537cd-3839-48df-a071-33b6c8552f49	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:37.188158+00	\N	\N	dagger	6	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 13:23:37.189625+00	2025-06-13 04:23:37.188158+00
1ad54d47-e3c3-49d1-a475-9a67a506c576	3eff4c88-d2a0-4b1f-8c71-f4be62e7f476	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:23:37.188158+00	\N	\N	staff	7	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:23:37.189625+00	2025-06-13 04:23:37.188158+00
de1a75ad-95a1-4b74-9d5a-03085dcb3c2f	c0564312-8670-45b4-99bd-072eaf075765	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:14.491806+00	\N	\N	staff	4	52	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:30:14.494091+00	2025-06-13 04:30:14.491806+00
a852c942-7f45-4f3a-80e1-c0668b8c5bef	6b4fc65b-95c5-467d-b320-89add7311a69	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:14.491806+00	\N	\N	bow	19	285	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 07:30:14.494091+00	2025-06-13 04:30:14.491806+00
3fb33d74-ea93-4443-b780-748acd9c7e4d	73cc60c0-600c-4905-b620-c78387cf23d1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:14.491806+00	\N	\N	sword	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:30:14.494091+00	2025-06-13 04:30:14.491806+00
b69c160d-6780-4326-9512-2ef001cd162e	31e58594-ede1-4a05-8efd-0f021e6b9869	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:14.491806+00	\N	\N	sword	7	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:30:14.494091+00	2025-06-13 04:30:14.491806+00
1359a747-3c00-4017-8738-1c319e3a2c0c	23cded0b-88f4-4d76-b192-ecf7dbc77ae2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:14.491806+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 08:30:14.494091+00	2025-06-13 04:30:14.491806+00
56b5cdb3-fa3c-4071-b2c2-2e31ae606a4e	ffbfa2ed-1197-4841-bc63-1d8598c7e5ab	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:43.898343+00	\N	\N	staff	6	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:30:43.899584+00	2025-06-13 04:30:43.898343+00
627570f6-72c9-483f-ae11-c1477b41863e	de13c749-4f30-492c-83eb-d7ee5f1b9f8e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:43.898343+00	\N	\N	hammer	5	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:30:43.899584+00	2025-06-13 04:30:43.898343+00
9b484ab9-db54-402c-8f6e-2ecef8a767bc	90d45278-1d1d-4850-b6ed-b4377d173595	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:43.898343+00	\N	\N	dagger	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:30:43.899584+00	2025-06-13 04:30:43.898343+00
91de05f3-145e-4cde-b182-b5181f2c311c	478935d9-1f75-4707-af69-324c76ada51c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:43.898343+00	\N	\N	staff	3	52	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:30:43.899584+00	2025-06-13 04:30:43.898343+00
fe16c87c-2d55-47c0-a794-54cdae41e035	6751161d-7582-4ef7-a672-8df02cc097de	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:30:43.898343+00	\N	\N	dagger	17	255	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:30:43.899584+00	2025-06-13 04:30:43.898343+00
acbc4ad9-cc74-4245-8ebc-b22a1582d6c8	d36cac0d-9b74-4485-a793-d7dd090b5880	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:16.201778+00	\N	\N	hammer	5	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:31:16.204784+00	2025-06-13 04:31:16.201778+00
f131ca57-557b-4cb1-bc53-ffb8adb8cb95	333e235d-ccc9-4a49-9f34-3462f251be8d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:16.201778+00	\N	\N	bow	7	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:31:16.204784+00	2025-06-13 04:31:16.201778+00
b65d2e46-05a2-4092-b6cc-34132dd1bd70	0820dace-cf17-42e2-a10e-1ac43fa96c49	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:16.201778+00	\N	\N	bow	6	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:31:16.204784+00	2025-06-13 04:31:16.201778+00
30596218-799f-4fb2-918d-bde1e91fa489	5d52f39b-a422-45db-b54d-321549319055	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:16.201778+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:31:16.204784+00	2025-06-13 04:31:16.201778+00
d79b0620-9727-4527-a868-18333bc1ae3d	d2c58853-ca2b-4d53-a1f6-35c74b57251e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:16.201778+00	\N	\N	hammer	3	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 09:31:16.204784+00	2025-06-13 04:31:16.201778+00
5e62503a-c845-4e15-b598-9b77730da2a2	1c1cac4a-c533-49f7-9b8f-9e28c4fd91af	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:44.654684+00	\N	\N	hammer	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:31:44.658756+00	2025-06-13 04:31:44.654684+00
3afe6b02-42e7-404a-b030-e854d460cb86	ffe16366-0e95-4ad2-8fdb-a10601ea0a4e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:44.654684+00	\N	\N	staff	5	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 09:31:44.658756+00	2025-06-13 04:31:44.654684+00
976e7b8b-a98a-4af1-b4b3-8461543d7cd0	18c33247-b91d-4618-8ac7-05734d97c906	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:44.654684+00	\N	\N	bow	3	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:31:44.658756+00	2025-06-13 04:31:44.654684+00
4f4a2062-872a-4edc-9007-944f3bbc1dcd	73617d05-541e-4f6f-9c5a-35961360e715	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:44.654684+00	\N	\N	staff	20	175	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 14:31:44.658756+00	2025-06-13 04:31:44.654684+00
270bee05-3b54-4de8-b0e0-e417d2eec56e	38a57f4f-7846-448d-9fdf-63c936002ecd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:31:44.654684+00	\N	\N	staff	7	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:31:44.658756+00	2025-06-13 04:31:44.654684+00
dd7ea2fb-89a6-4417-ad2b-8204fa573f5d	7825e6a6-1207-4019-91e6-0227c2ccc648	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:13.934877+00	\N	\N	bow	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:32:13.935991+00	2025-06-13 04:32:13.934877+00
d07e146e-99bd-409b-bbc1-b8e3a2ea4bb2	7c1167c5-404e-48a3-9226-b19667ea4ec5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:13.934877+00	\N	\N	sword	19	209	rare	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 16:32:13.935991+00	2025-06-13 04:32:13.934877+00
6b4068cf-b4e4-49c9-b2b9-21545d9aac8f	a46933a1-9838-4155-8e63-febba3cce45d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:13.934877+00	\N	\N	bow	4	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:32:13.935991+00	2025-06-13 04:32:13.934877+00
cc813c3c-72c2-40d0-830e-f3a74f7cfaf4	f0cc67e1-a5aa-428f-8a30-e22142c7f639	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:13.934877+00	\N	\N	staff	20	175	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 22:32:13.935991+00	2025-06-13 04:32:13.934877+00
16ac9d2d-9484-4479-b30b-a15777863258	fabe59e1-8ae9-488a-9750-9d812afc7e03	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:43.94235+00	\N	\N	bow	20	300	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 04:32:43.943246+00	2025-06-13 04:32:43.94235+00
29ccce52-7ee9-43e9-a309-ce260bd991a0	ddda730f-7552-49d3-aee5-b9f8d124aa0f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:43.94235+00	\N	\N	dagger	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 08:32:43.943246+00	2025-06-13 04:32:43.94235+00
6f497db8-381f-43a2-8ef6-4fb29fb8a2d4	4692c6be-d584-42e8-b922-cb2530e26652	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:32:43.94235+00	\N	\N	dagger	5	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 07:32:43.943246+00	2025-06-13 04:32:43.94235+00
197d917c-5277-49c3-b604-ac0c85e95f11	d8d0513c-f9ff-4eb2-b3fa-4e50276edb84	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:13.927446+00	\N	\N	hammer	14	154	common	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 02:33:13.928346+00	2025-06-13 04:33:13.927446+00
a29b5829-d555-4e23-877a-4dc146f4f210	b5643976-1820-441d-93b7-865537660aac	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:13.927446+00	\N	\N	staff	6	52	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:33:13.928346+00	2025-06-13 04:33:13.927446+00
8aafba26-27af-4e5b-a1c1-c35b3895722a	7c330ff2-af5d-41e8-8522-6853d51df1de	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:13.927446+00	\N	\N	dagger	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:33:13.928346+00	2025-06-13 04:33:13.927446+00
ae20c920-3894-496d-a697-5e6638ece458	cf5ec501-43a0-4614-85c6-aec41a0aeb05	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:43.937274+00	\N	\N	sword	15	165	rare	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 04:33:43.938534+00	2025-06-13 04:33:43.937274+00
ca78e4d9-3fe5-4641-8e60-6a5c8b74ba34	eeacc40b-cbf5-44ea-84d9-a0ea2c8cd6a9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:43.937274+00	\N	\N	dagger	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:33:43.938534+00	2025-06-13 04:33:43.937274+00
54f27d5a-f296-481c-b351-110db646ee64	fe378b49-60e7-4b18-ab45-0d351746c532	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:33:43.937274+00	\N	\N	bow	19	285	rare	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 16:33:43.938534+00	2025-06-13 04:33:43.937274+00
75fd3ff3-a44d-4001-8bef-bad7f0a03140	da4e74db-69bc-4475-a659-1ffc979cfa15	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:13.951578+00	\N	\N	bow	4	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:34:13.952951+00	2025-06-13 04:34:13.951578+00
02043585-5b5d-40f8-a0f5-b1d682f86e04	fa99dfc5-09fe-481c-a259-a57d6a25283d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:13.951578+00	\N	\N	sword	4	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:34:13.952951+00	2025-06-13 04:34:13.951578+00
052ad2cf-e5d3-4e74-9586-69ef7c636ae8	d26e7ab6-f077-469b-b4dd-e78503a53fc4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:13.951578+00	\N	\N	hammer	5	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:34:13.952951+00	2025-06-13 04:34:13.951578+00
dad7d2c7-670b-4f6f-a041-468f6dc855b1	93e2df74-73d5-495c-8e7e-cf39bda2d814	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:13.951578+00	\N	\N	staff	6	52	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 07:34:13.952951+00	2025-06-13 04:34:13.951578+00
6c1f5aa2-e0ef-4908-863a-affee37159cb	cfc609bf-1687-47cf-8249-8ae47aa8e088	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:13.951578+00	\N	\N	sword	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:34:13.952951+00	2025-06-13 04:34:13.951578+00
f691f4f6-25ea-44f3-a012-6399aac72063	815ec805-5fca-4f9b-b95e-3a1f7b9d2f03	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:13.919317+00	\N	\N	bow	16	240	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 13:35:13.920988+00	2025-06-13 04:35:13.919317+00
85a2ac63-ae81-45af-9af4-542e9eb39af4	e82110e5-2f5f-4e99-8110-3668b2a0f0f1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:13.919317+00	\N	\N	hammer	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:35:13.920988+00	2025-06-13 04:35:13.919317+00
094e0483-e057-4d5a-8260-1bb5d7ca361f	0615bdb3-1586-41ff-96aa-7306b0e33003	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:13.919317+00	\N	\N	staff	7	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:35:13.920988+00	2025-06-13 04:35:13.919317+00
b4c0b0d7-3503-4231-95e2-747c657f7567	62b1db72-0152-4f99-a155-45f871ade112	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:13.919317+00	\N	\N	staff	16	140	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 15:35:13.920988+00	2025-06-13 04:35:13.919317+00
aceafe44-f5dc-4a0e-9d2f-1c0143b25d6c	a0955fce-8d36-4040-ad44-e5d91a466796	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:13.919317+00	\N	\N	sword	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:35:13.920988+00	2025-06-13 04:35:13.919317+00
4a01c4a6-9a41-4d0c-b211-8d7194e6096f	df11e8ae-aab7-4ecd-b78a-81a93d259383	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:43.912078+00	\N	\N	hammer	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:34:43.913249+00	2025-06-13 04:34:43.912078+00
7cb62c11-7c0e-4a82-9efa-e71b11faabcf	0c5d018f-d472-4aa2-8d3f-d3f42d95f532	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:43.912078+00	\N	\N	sword	15	165	rare	2	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 16:34:43.913249+00	2025-06-13 04:34:43.912078+00
d3e4232d-1268-4b4a-aefe-4fb674639c88	096efd18-6bd3-4e77-a746-ae933155d13a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:43.912078+00	\N	\N	dagger	3	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:34:43.913249+00	2025-06-13 04:34:43.912078+00
667e697c-5024-4f9a-ba5c-76461ea59c3e	e50c81b6-0082-4e75-8edb-a1912f8f187a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:34:43.912078+00	\N	\N	sword	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:34:43.913249+00	2025-06-13 04:34:43.912078+00
afb9882e-6f53-4fdd-a4df-3bb907fe1a8e	48629ae9-8d0c-4837-a660-0ab4c7f0adf1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:44.055748+00	\N	\N	sword	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:35:44.088245+00	2025-06-13 04:35:44.055748+00
f3d95709-0dba-487c-8a7b-e92bc66af11f	8898206a-70ce-4426-b196-ea44547f0a66	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:44.055748+00	\N	\N	staff	6	52	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:35:44.088245+00	2025-06-13 04:35:44.055748+00
ebf0497f-afde-48c2-acbf-29868706887c	7eb27cda-3141-4f5c-aca7-01e977e75d6d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:44.055748+00	\N	\N	sword	18	198	common	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 15:35:44.088245+00	2025-06-13 04:35:44.055748+00
38093fc0-3191-492c-976a-5fac51b7da70	9478daa6-9448-4f25-b530-1dc8e4913685	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:44.248767+00	\N	\N	sword	5	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:35:44.250145+00	2025-06-13 04:35:44.248767+00
41ba6150-694e-4723-b9fa-7a5f2e45f60a	d8ef96e2-e5f5-447a-9993-173a2ada848a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:35:44.248767+00	\N	\N	staff	17	148	epic	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 00:35:44.250145+00	2025-06-13 04:35:44.248767+00
c2ad67f3-f496-4445-a4c3-e36505aeb6d0	2d764028-2257-4943-a15e-f134663a29f0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:14.206779+00	\N	\N	bow	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:36:14.207848+00	2025-06-13 04:36:14.206779+00
a3cecf42-6254-422b-b660-20e68d372e07	387cc13c-1f9c-4680-a263-c8ae7b120527	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:14.206779+00	\N	\N	sword	5	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:36:14.207848+00	2025-06-13 04:36:14.206779+00
a66cc0bb-7033-4992-9272-a92e018ce498	c3ae87e2-7d1c-45a5-96fa-2130d38a70c3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:14.206779+00	\N	\N	hammer	16	176	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 01:36:14.207848+00	2025-06-13 04:36:14.206779+00
1588f9a4-1feb-47c8-8c5a-1de005a31fdc	c87143b9-5192-455a-b03d-492d3b04ecdb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:50.289085+00	\N	\N	staff	6	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:36:50.289807+00	2025-06-13 04:36:50.289085+00
f0108831-1d66-42b2-8dc5-8e15f7e41ccd	bab16334-1799-4e87-9889-d58065363539	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:50.289085+00	\N	\N	staff	20	175	common	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 11:36:50.289807+00	2025-06-13 04:36:50.289085+00
9b181ea0-9035-4440-a3cb-dd2e5d3490e3	69381ce2-3bf6-4cdf-94e4-a1881c5f3dc5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:50.289085+00	\N	\N	bow	19	285	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 04:36:50.289807+00	2025-06-13 04:36:50.289085+00
525bea62-d8bf-4939-b397-2a26bb25cbec	090d4877-e73d-4858-a987-d31329cb92fd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:50.289085+00	\N	\N	sword	3	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:36:50.289807+00	2025-06-13 04:36:50.289085+00
1181dc6d-d101-4855-abac-d38d07792b63	1cc853b9-39c5-4138-9c00-1261e415aced	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:36:50.289085+00	\N	\N	staff	5	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 10:36:50.289807+00	2025-06-13 04:36:50.289085+00
fbaeffc3-ccee-466f-b9c8-d58c7334cc3b	7759cc44-470b-458b-b7ae-33ad320cafe8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:14.200141+00	\N	\N	sword	4	66	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:37:14.200929+00	2025-06-13 04:37:14.200141+00
ab377cb1-2fb0-4087-804a-87abc6de6a46	b338697c-63cf-4154-8cfd-a96c6db85f19	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:14.200141+00	\N	\N	bow	6	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:37:14.200929+00	2025-06-13 04:37:14.200141+00
0f4879f0-6889-427a-87d0-66b60cf29736	d030ec5b-585a-4c79-8c43-539ac7832236	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:14.200141+00	\N	\N	sword	4	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:37:14.200929+00	2025-06-13 04:37:14.200141+00
17419014-363f-4ff5-8edc-3918b5d52986	3ea0995c-578b-45a9-828d-a17cb686a368	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:14.200141+00	\N	\N	bow	7	90	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:37:14.200929+00	2025-06-13 04:37:14.200141+00
08b7748e-93d4-466f-98a0-f4ee514e64cf	a71de161-379a-4a2e-b0c9-0b9b69331e4c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:14.200141+00	\N	\N	staff	3	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 12:37:14.200929+00	2025-06-13 04:37:14.200141+00
7fb535ff-519c-4dfe-981b-9f866d16e5ac	26010756-87be-4cd9-8f7b-3d54ab8044a2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:44.1654+00	\N	\N	staff	3	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:37:44.166979+00	2025-06-13 04:37:44.1654+00
dcbbdefa-a9bc-47bc-ab53-a45344617d34	44544391-458f-4ec2-9f24-4f972650935e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:44.1654+00	\N	\N	dagger	3	90	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:37:44.166979+00	2025-06-13 04:37:44.1654+00
49b492bc-bf93-4dfc-a0a1-9d40f5b4a13a	a35e96e8-2210-42c2-ab72-425925f9d760	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:37:44.1654+00	\N	\N	dagger	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:37:44.166979+00	2025-06-13 04:37:44.1654+00
be0fdb46-5237-409c-9650-29819202e873	628060f5-575f-4392-abf5-9c2df82508ae	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:13.918708+00	\N	\N	bow	18	270	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 16:38:13.919529+00	2025-06-13 04:38:13.918708+00
16fb57ec-94a8-439c-b105-5043ce175e50	800d476a-c868-4371-b5dd-559357c76683	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:13.918708+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:38:13.919529+00	2025-06-13 04:38:13.918708+00
063ad82b-0359-49d3-8ceb-91deef37b51f	c15fd9bf-0b66-41e4-9b51-860f674b0ef8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:43.919403+00	\N	\N	bow	7	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:38:43.920193+00	2025-06-13 04:38:43.919403+00
a50ee3e2-7a8d-436e-b6ab-032e953bc9ad	09e8569c-92a5-4345-a55d-65850e04a8ed	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:43.919403+00	\N	\N	staff	13	113	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 16:38:43.920193+00	2025-06-13 04:38:43.919403+00
11e4f46b-0b85-4509-afa9-4662d6ec81f8	216dfd14-bcb8-40f0-8ac8-a563b48f4698	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:43.919403+00	\N	\N	hammer	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:38:43.920193+00	2025-06-13 04:38:43.919403+00
ece4c45c-1796-4da4-90fc-4da829f40758	c80c8bdc-f41c-44a7-8e24-71b5f9d58bb7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:43.919403+00	\N	\N	hammer	7	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:38:43.920193+00	2025-06-13 04:38:43.919403+00
1bec8cf0-f1f4-4f73-8ca7-5c9dc95493e4	7b4a0096-1c28-46f4-bb6f-a5875f2eddf1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:38:43.919403+00	\N	\N	sword	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:38:43.920193+00	2025-06-13 04:38:43.919403+00
4c6d0f04-1722-455c-8720-4a2d15a78bdd	7458a20a-34d3-4ff3-bde3-b5a20e1f7e49	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:13.874397+00	\N	\N	dagger	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:39:13.875425+00	2025-06-13 04:39:13.874397+00
3d42b835-6f2c-4be5-919b-890f55e4ec00	8e0dc2bf-5a0c-407e-8f39-d77903136d6d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:13.874397+00	\N	\N	dagger	5	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:39:13.875425+00	2025-06-13 04:39:13.874397+00
ca9f7593-311c-43d9-99cf-5f56ddc1bada	290e2fa1-d3c6-4be6-a7ab-c4e5a28671fa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:13.874397+00	\N	\N	bow	5	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 10:39:13.875425+00	2025-06-13 04:39:13.874397+00
bd1f8c90-f571-42f1-8eca-097188bb8ee1	6bb83cd7-e49d-47a2-a576-ada273129282	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:13.874397+00	\N	\N	sword	6	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:39:13.875425+00	2025-06-13 04:39:13.874397+00
97b60cd2-9467-4341-a94e-82fbf270f481	b84f06f5-1312-4a66-aae9-2200819118c6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:13.874397+00	\N	\N	sword	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:39:13.875425+00	2025-06-13 04:39:13.874397+00
e502d86a-b80b-47ef-85a4-77ee3c7762f1	4d2dce7c-9151-4e6f-914a-63f20dc7647b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:43.898607+00	\N	\N	hammer	3	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:39:43.899968+00	2025-06-13 04:39:43.898607+00
57b97a54-f826-49a0-a6d4-1a5a5e093fb3	399b1792-f718-4057-baa2-f2de1cc25046	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:43.898607+00	\N	\N	sword	15	165	common	2	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 22:39:43.899968+00	2025-06-13 04:39:43.898607+00
fc6ab6b6-4a91-4fbc-8817-a8e0818542b8	d4bcc374-9c63-4c86-b725-61c5d28d164a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:43.898607+00	\N	\N	bow	7	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:39:43.899968+00	2025-06-13 04:39:43.898607+00
1c61d5b0-6c35-4aec-a173-bfbd27b62f82	36a9b629-a874-4bd9-aeec-de42ec32f816	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:39:43.898607+00	\N	\N	staff	4	52	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 13:39:43.899968+00	2025-06-13 04:39:43.898607+00
64827429-875f-4384-b100-d4f41ceb90f1	0f432004-65bd-4c07-8f62-8fd006f49826	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:01.959179+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:40:01.961126+00	2025-06-13 04:40:01.959179+00
d1a8ad4e-e882-461c-9cb8-7e6059c577da	e869a6f0-9be4-4b4c-85da-f03ac30b92e1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:01.959179+00	\N	\N	sword	6	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:40:01.961126+00	2025-06-13 04:40:01.959179+00
9d07c56b-7c9c-44ba-b2ce-1f48f6a93c0e	280d6a21-8155-478d-bdd9-54370049960d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:01.959179+00	\N	\N	dagger	6	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 10:40:01.961126+00	2025-06-13 04:40:01.959179+00
7ecd406a-ac40-43ea-9d63-818906fe8878	d6ee773b-e0db-4c48-9139-c07ceb78156d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:01.959179+00	\N	\N	bow	7	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:40:01.961126+00	2025-06-13 04:40:01.959179+00
6393a891-0a60-4d0e-9467-1ec15e62f5b3	39847d5e-b040-4ebe-b9e4-c1331270ca3b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:01.959179+00	\N	\N	staff	3	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 11:40:01.961126+00	2025-06-13 04:40:01.959179+00
0ba28b50-b63e-43dc-badd-095b3feed8b2	ec63ce83-9c05-4536-8d37-0be63d749732	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:30.106607+00	\N	\N	dagger	15	225	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 23:40:30.107507+00	2025-06-13 04:40:30.106607+00
5918219c-444d-4402-b4a8-8fea517aba9b	1ac8f165-17e0-4089-bce6-3c1ad86fd62e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:30.106607+00	\N	\N	staff	3	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:40:30.107507+00	2025-06-13 04:40:30.106607+00
fd439230-c728-4474-a084-fca2e9dadbc9	4fe528a5-5d63-4035-96b1-5758f4136b33	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:30.106607+00	\N	\N	staff	5	52	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:40:30.107507+00	2025-06-13 04:40:30.106607+00
17ed03ea-6b78-400f-a211-23c0397c9697	c963df34-7c5c-45ac-a8d2-d61d542b0b3a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:30.106607+00	\N	\N	bow	14	210	epic	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:40:30.107507+00	2025-06-13 04:40:30.106607+00
e3f6bde9-9ed0-4a46-8b3a-4ec44b4e77a4	2d5c376b-ef37-4182-a24d-52121f0407ac	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:30.106607+00	\N	\N	staff	7	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:40:30.107507+00	2025-06-13 04:40:30.106607+00
d6c919ea-645c-42ce-8921-41b2681b52e3	38f83e6e-e682-43f1-aea1-d917c2f8c861	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:31.909496+00	\N	\N	bow	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:40:31.910838+00	2025-06-13 04:40:31.909496+00
93559243-54db-405e-ba45-701bce01e841	36c607e3-341c-4c47-a272-7ad9015561d5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:31.909496+00	\N	\N	hammer	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:40:31.910838+00	2025-06-13 04:40:31.909496+00
d4197c1c-b6cc-4089-90c2-7e00d1543b74	f65d4f9d-be89-41e9-94a0-da271db92ba2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:31.909496+00	\N	\N	sword	7	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:40:31.910838+00	2025-06-13 04:40:31.909496+00
43560a07-7b7b-42ac-aaab-b9a256c43187	1fe90804-f35f-4eed-8d1a-9d37ffc8c8f9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:31.909496+00	\N	\N	bow	3	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:40:31.910838+00	2025-06-13 04:40:31.909496+00
5c995dfc-25f8-4558-9eb3-b103842080d3	224761dc-56dc-4536-a3dd-ff92dcfdf4eb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:31.909496+00	\N	\N	sword	6	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:40:31.910838+00	2025-06-13 04:40:31.909496+00
f7489625-b790-428f-9660-ad1731891ff8	57beea03-5c04-450c-9510-8d4d0eb5d6ea	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:45.826808+00	\N	\N	sword	5	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:40:45.82818+00	2025-06-13 04:40:45.826808+00
d80a2626-7f2e-4b96-aafc-a93d9dd7bf2c	d8ef4936-5760-4699-8830-9ee45f073cc8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:45.826808+00	\N	\N	staff	5	52	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 12:40:45.82818+00	2025-06-13 04:40:45.826808+00
d645dfdb-b58b-4517-907e-75cebef60c97	6bfbe7af-add1-48e0-b1ad-a00b5a0c79d2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:45.826808+00	\N	\N	dagger	5	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 07:40:45.82818+00	2025-06-13 04:40:45.826808+00
40e6d72e-2921-49d8-a091-19908e61417d	8c645644-2049-42a1-9ca0-4e521b1c84da	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:40:45.826808+00	\N	\N	staff	4	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:40:45.82818+00	2025-06-13 04:40:45.826808+00
b6361952-18f8-45a8-ba1e-3a49d20096f7	bdc7ea04-7ab7-441b-a392-65120db2a046	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:01.841584+00	\N	\N	dagger	14	210	epic	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:41:01.84259+00	2025-06-13 04:41:01.841584+00
11b59cfa-3802-4021-bb75-86da613f4fbe	e3fe8348-71cc-4b41-bc9d-e8475a679a37	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:01.841584+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:41:01.84259+00	2025-06-13 04:41:01.841584+00
4b1eed3f-3de8-47cd-9e9d-fd98ecb9e5e1	c8fa356a-b0cd-4e2b-8c12-365299747213	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:31.925671+00	\N	\N	staff	16	140	common	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 15:41:31.926881+00	2025-06-13 04:41:31.925671+00
a88618f0-4a68-41af-acea-86cb052046e2	5ef68eec-f44a-4415-acc5-c78ed456b378	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:31.925671+00	\N	\N	bow	13	195	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 15:41:31.926881+00	2025-06-13 04:41:31.925671+00
dc4dad66-8cd0-4c82-98be-f0c747c58362	7f470bfb-1b1a-4c18-827c-9137368b96b7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:36.819306+00	\N	\N	bow	3	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 10:41:36.820541+00	2025-06-13 04:41:36.819306+00
1e05387c-7b8f-4011-bd25-0061e9687a41	103cdaf8-f63f-41c7-8b69-af3fc38d24c6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:36.819306+00	\N	\N	sword	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:41:36.820541+00	2025-06-13 04:41:36.819306+00
d2629834-9daf-449f-aba7-64fa7c0952c4	efdfaaf1-cb69-443f-b3d2-60780aa400e9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:36.819306+00	\N	\N	hammer	16	176	epic	2	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 02:41:36.820541+00	2025-06-13 04:41:36.819306+00
c36b20be-f98d-4e9b-af0f-c78faa7b4109	093baa69-64c3-41d2-8c05-7ee2570060ce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:41:36.819306+00	\N	\N	hammer	6	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:41:36.820541+00	2025-06-13 04:41:36.819306+00
764a93e8-caa4-4af7-8849-baae349a742b	b3039566-2f01-4650-ae7e-a15ad3d2c28c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:42:04.069229+00	\N	\N	bow	7	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:42:04.070289+00	2025-06-13 04:42:04.069229+00
6183953e-67e7-452a-8126-e9da790b2d33	d5ff2293-86e7-4ecf-ada0-9a5baf850c01	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:42:04.069229+00	\N	\N	dagger	5	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:42:04.070289+00	2025-06-13 04:42:04.069229+00
f286b8f9-e174-4097-942f-0fc36094da26	57b1f060-5686-4b79-a026-917515d9701a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:42:31.920716+00	\N	\N	hammer	6	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:42:31.921688+00	2025-06-13 04:42:31.920716+00
f32cd96e-65ae-44e2-a8fd-45dd6ad73855	e21bcebc-8ad8-4fff-8091-5638d0ced3eb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:42:31.920716+00	\N	\N	sword	6	66	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:42:31.921688+00	2025-06-13 04:42:31.920716+00
863c2c54-8fb2-4b2e-9dc7-889153fac2fb	5b45df2d-8851-4f87-ba13-0544cf299ec8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:42:31.920716+00	\N	\N	hammer	4	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:42:31.921688+00	2025-06-13 04:42:31.920716+00
85b08d87-05f6-4dde-935b-ee34f2f9912a	958085ac-2622-4694-8faa-3f8c89a10bf9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:01.842236+00	\N	\N	sword	13	143	rare	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 07:43:01.843569+00	2025-06-13 04:43:01.842236+00
dc87159c-305c-4e24-963a-1a4b9f44892e	1907ae80-45a6-4b2f-95dd-2b3e84c2b82c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:01.842236+00	\N	\N	hammer	6	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:43:01.843569+00	2025-06-13 04:43:01.842236+00
2febba58-3d57-475a-b97b-45d6d5704008	a6c2c913-bf0e-4358-b6a7-2f01656c65e7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:01.842236+00	\N	\N	staff	5	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 13:43:01.843569+00	2025-06-13 04:43:01.842236+00
8320649f-1df9-418b-9257-45ca065b6212	22f8c5be-7aa4-4ea6-bb0a-5eb101ce65a8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:01.842236+00	\N	\N	dagger	3	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:43:01.843569+00	2025-06-13 04:43:01.842236+00
9508503d-bf67-4d63-a9ec-777be383098e	b5d01b89-b5ce-46cc-9223-9127b241f13f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:32.164421+00	\N	\N	bow	7	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 13:43:32.165173+00	2025-06-13 04:43:32.164421+00
1247077a-0bc1-446c-8629-504d28ad7124	84cfcd5f-e6b4-4a05-bb0f-0fec7c09cb3a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:43:32.164421+00	\N	\N	staff	15	131	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 14:43:32.165173+00	2025-06-13 04:43:32.164421+00
81c431b1-23d5-417e-95c3-6126b3f146f3	87141734-bed9-42a7-be29-f593acaf66ba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:44:01.852362+00	\N	\N	staff	6	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 07:44:01.853488+00	2025-06-13 04:44:01.852362+00
327a2dd1-2d16-4583-9920-60b10b1bd649	31a31bb0-3e62-449e-a7f3-301c6655039a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:44:01.852362+00	\N	\N	staff	6	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:44:01.853488+00	2025-06-13 04:44:01.852362+00
06b458a5-9bbd-4562-83e8-7a468b1dedc1	4d747867-3a39-45cd-803e-cdaa17d8e075	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:44:32.151948+00	\N	\N	staff	16	140	epic	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 17:44:32.153757+00	2025-06-13 04:44:32.151948+00
74338520-ccba-45ae-b5f8-d7e0c2981c3c	5c3dd98d-4a88-4ab0-ac2d-9801873a946a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:44:32.151948+00	\N	\N	hammer	7	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:44:32.153757+00	2025-06-13 04:44:32.151948+00
50b77753-7678-4ba0-8c0f-5f27ccef4c7b	3d9a9476-6d96-4f10-a4d6-42d0adaa51fd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:01.995312+00	\N	\N	hammer	5	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:45:02.045925+00	2025-06-13 04:45:01.995312+00
55214552-b251-4847-bf96-48a35f640dc1	d56b379b-617b-40f2-b1a8-c33cca540aa5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:01.995312+00	\N	\N	staff	5	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 09:45:02.045925+00	2025-06-13 04:45:01.995312+00
e89c4513-02c3-4bad-b98a-6270a7fba2e5	f80115b8-f0f6-46a8-a078-ac1e866eb0bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:01.995312+00	\N	\N	bow	19	285	epic	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:45:02.045925+00	2025-06-13 04:45:01.995312+00
08384fbf-12f2-4ef3-abf4-1d1422144252	ec31fb70-b2e1-4717-8dd6-4c498114fcf6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:01.995312+00	\N	\N	hammer	5	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:45:02.045925+00	2025-06-13 04:45:01.995312+00
5dae3f22-27f5-4e88-9f74-4426e1435ac0	fd1df051-bcf8-446c-9cec-8282b8637f64	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:01.995312+00	\N	\N	bow	5	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 13:45:02.045925+00	2025-06-13 04:45:01.995312+00
6020d334-a8ba-4d13-a1e9-d446040121e3	887eab59-c6c5-4e91-a4e4-2ccc7433f0bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:02.311751+00	\N	\N	hammer	16	176	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 13:45:02.313799+00	2025-06-13 04:45:02.311751+00
2322b1b9-32a9-4587-9a58-d00be6d554e9	632153bf-cb66-47bb-92d2-328dfa22eb8b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:02.311751+00	\N	\N	sword	5	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:45:02.313799+00	2025-06-13 04:45:02.311751+00
6382aaa4-1731-4684-8974-8db99bb3de95	3a454f27-a33e-4a09-8f9b-9c1892ae66dd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:02.311751+00	\N	\N	sword	6	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:45:02.313799+00	2025-06-13 04:45:02.311751+00
d1bc32ed-592d-469f-a150-117810882b01	20a5bbe8-5fea-43d3-a148-75dca466738b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:02.311751+00	\N	\N	sword	3	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:45:02.313799+00	2025-06-13 04:45:02.311751+00
2508487b-bc36-4c72-b2d7-603435b04e85	779610fa-ab55-49ed-bfbb-6bbf21b3427c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:02.311751+00	\N	\N	dagger	3	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:45:02.313799+00	2025-06-13 04:45:02.311751+00
a70218fc-c466-495b-9f93-0de75af3a455	298805be-d142-48a4-b10e-b08a2d13ff50	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:47.005002+00	\N	\N	bow	3	90	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:45:47.008313+00	2025-06-13 04:45:47.005002+00
464ef4ba-8a2c-4fce-be7c-b844501f2416	8aa3d2d6-fa4a-44aa-8a6f-f374874a3c5f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:47.005002+00	\N	\N	dagger	15	225	common	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:45:47.008313+00	2025-06-13 04:45:47.005002+00
2fa6d99d-46a4-4a48-bb66-c5e3d862f02c	97dacd96-aedb-4a90-9f38-4c725f65fd49	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:47.005002+00	\N	\N	dagger	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 07:45:47.008313+00	2025-06-13 04:45:47.005002+00
729e82b3-8fd3-4080-8270-5fb5de53b518	9c26eeae-92f4-422f-8b47-fc4c0f326b20	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:56.92433+00	\N	\N	staff	3	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:45:56.925226+00	2025-06-13 04:45:56.92433+00
0a5e99e9-fa38-41ff-a40d-90b78695fdb9	61c63dc0-f1d3-4139-8df8-d0e56fcc8eba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:56.92433+00	\N	\N	sword	14	154	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 02:45:56.925226+00	2025-06-13 04:45:56.92433+00
9c046ddc-ea96-4902-8070-fdfc91187739	54e5a98d-d5f9-47b7-ab7b-d949474c2c1a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:45:56.92433+00	\N	\N	bow	4	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:45:56.925226+00	2025-06-13 04:45:56.92433+00
82e4f9a3-8813-4edc-a651-848b91fdf642	0e5794cc-babb-458a-8d12-d459d6683643	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:26.803036+00	\N	\N	staff	5	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:46:26.803896+00	2025-06-13 04:46:26.803036+00
fcacb1c7-d35f-476f-ae04-a63d5d0e6ae6	433719e8-fe6e-4138-9a93-4a8ec3adeb7f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:26.803036+00	\N	\N	hammer	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:46:26.803896+00	2025-06-13 04:46:26.803036+00
5a4c0f80-3071-41f0-9805-80fc5fe7aa00	6551c57f-0d43-4197-816d-5eb13fa22ec0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:26.803036+00	\N	\N	staff	18	157	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 08:46:26.803896+00	2025-06-13 04:46:26.803036+00
a1e5a48b-3ec0-4b79-8e20-550f2bfde645	7b1981f5-ee13-403f-a3a1-d89fc09b12ab	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:26.803036+00	\N	\N	dagger	4	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:46:26.803896+00	2025-06-13 04:46:26.803036+00
c364a3cf-3566-456a-8e0f-41fad1bf170c	15f48f82-4f6c-4d82-8767-7d4efb2d42c9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:26.803036+00	\N	\N	staff	19	166	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 17:46:26.803896+00	2025-06-13 04:46:26.803036+00
b06f05bf-448f-48e3-b4de-33b869e51127	2c33e8f5-306f-4563-a1b4-7d226d6b205c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:43.623318+00	\N	\N	staff	4	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:46:43.624803+00	2025-06-13 04:46:43.623318+00
58c69c95-df24-456e-9490-bddb1aaa8fc0	61b507ce-27c7-4c0c-b476-1bfadc59d5b7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:43.623318+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:46:43.624803+00	2025-06-13 04:46:43.623318+00
6eb80ae1-f21d-4a49-98c2-e3e208f3dc28	a28a49b3-c4a4-4022-8ff8-46c05f3823ef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:43.623318+00	\N	\N	dagger	18	270	rare	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 09:46:43.624803+00	2025-06-13 04:46:43.623318+00
02776cc7-f8cc-4a50-9a34-de8739484aba	fea88a57-9a09-4a06-9736-2251197f11f4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:43.623318+00	\N	\N	hammer	6	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:46:43.624803+00	2025-06-13 04:46:43.623318+00
3d4c0ef3-cacc-4b60-9d35-21a2342542b3	2412718f-3b0c-420e-8bc5-cbd932b6cfde	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:56.846031+00	\N	\N	dagger	7	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:46:56.84704+00	2025-06-13 04:46:56.846031+00
7549ab98-f71b-441f-b523-913ce5d1d9d4	deef7eaa-80e0-4b3e-b940-4dd3179e2711	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:56.846031+00	\N	\N	hammer	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:46:56.84704+00	2025-06-13 04:46:56.846031+00
14ffe99c-4bc5-4dc8-a0df-c9732d635a09	05fb5f10-22a9-4159-a812-3a42edeed8fa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:56.846031+00	\N	\N	sword	5	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:46:56.84704+00	2025-06-13 04:46:56.846031+00
1ebf9b4d-d368-41e8-9998-d9c062299da3	d960828e-420f-4d13-9028-927293a37e28	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:56.846031+00	\N	\N	bow	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:46:56.84704+00	2025-06-13 04:46:56.846031+00
0ed26390-7357-46f6-82bd-8202bcc91503	4989ccb6-4992-42b8-a827-53d20aa681f8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:46:56.846031+00	\N	\N	dagger	6	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:46:56.84704+00	2025-06-13 04:46:56.846031+00
0882c149-5f22-42bb-9e05-5f9324a8cf7b	2f6eec57-9b80-48de-aab7-a1841e71fec6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:26.920958+00	\N	\N	sword	4	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:47:26.925713+00	2025-06-13 04:47:26.920958+00
4ce1c034-a86b-4ae4-90e2-b9471bebf3c0	f5bc0ffd-92ad-4a6a-b8f6-8925b57ea0e9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:26.920958+00	\N	\N	hammer	19	209	rare	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 00:47:26.925713+00	2025-06-13 04:47:26.920958+00
d7291355-d1e3-4993-b7e5-0672ad999a59	5253c2dd-57da-4c97-a061-4d84a710ca50	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:46.661771+00	\N	\N	bow	17	255	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:47:46.662797+00	2025-06-13 04:47:46.661771+00
03cbedbb-1e0b-499b-a097-8d9d89aa312e	fe2b6409-3e2a-4f4f-817f-56ba71a2d916	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:46.661771+00	\N	\N	dagger	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:47:46.662797+00	2025-06-13 04:47:46.661771+00
de248bb1-9588-45de-a564-7d36e9dcef37	2f64ceb6-7bf2-43fe-9110-a9a5eec8d0ba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:46.661771+00	\N	\N	bow	15	225	common	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 08:47:46.662797+00	2025-06-13 04:47:46.661771+00
7d2ccbdc-c862-4d57-a3b6-6b066c295fc5	bb732637-7d99-4886-acbf-d6c651aa36b2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:46.661771+00	\N	\N	hammer	20	220	epic	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 00:47:46.662797+00	2025-06-13 04:47:46.661771+00
2d09f784-8f87-43ba-b279-72510813f201	35da8604-6a61-4164-9408-4a2868cdb0a4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:46.661771+00	\N	\N	staff	6	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 13:47:46.662797+00	2025-06-13 04:47:46.661771+00
d5de18da-42e6-475e-b743-1a3c9af347df	4d5dcb7e-1590-4f21-bc7c-b4d93278f1a1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:56.78733+00	\N	\N	bow	4	90	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:47:56.788681+00	2025-06-13 04:47:56.78733+00
c1fd1455-75ff-4b85-954f-8ff0493cd5b8	9ad94b34-9b05-4398-abf7-a8666af8e94c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:56.78733+00	\N	\N	dagger	6	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:47:56.788681+00	2025-06-13 04:47:56.78733+00
904ed58c-6855-4ca7-8622-093d3443ff5e	c4fb8966-cb4f-49c8-9eb7-80e03c6ec3ad	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:47:56.78733+00	\N	\N	dagger	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:47:56.788681+00	2025-06-13 04:47:56.78733+00
441dc44e-2762-4352-8bc5-6b10dac988db	f728110b-7d25-4d7f-9cc7-c59f122edf45	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:26.994344+00	\N	\N	bow	19	285	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 13:49:26.996818+00	2025-06-13 04:49:26.994344+00
9311fd51-68d1-4727-a001-5c32e6f0ad94	cdcb9e6f-66e9-4638-ae0e-193af2caf9b7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:26.994344+00	\N	\N	hammer	4	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:49:26.996818+00	2025-06-13 04:49:26.994344+00
b0eda12b-4d56-429d-a61b-85eca9b73986	f9592cdd-8f9d-4b6c-b544-1db258269cdd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:31.736429+00	\N	\N	staff	18	157	epic	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:49:31.738196+00	2025-06-13 04:49:31.736429+00
7301cc69-a59f-4163-9b0c-1384f47edefb	6eae64ab-73f0-4523-a6bb-ddb38ff20b1e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:31.736429+00	\N	\N	staff	4	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 08:49:31.738196+00	2025-06-13 04:49:31.736429+00
38859df4-48c8-4362-a197-97b7b8ad5944	422e1ee4-e007-4694-848a-39d52fca8654	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:31.736429+00	\N	\N	staff	3	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:49:31.738196+00	2025-06-13 04:49:31.736429+00
1d41190f-175d-4012-ad84-250956229817	e6900be4-e22f-4440-8c79-fbcec8886b90	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:31.736429+00	\N	\N	sword	15	165	common	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 01:49:31.738196+00	2025-06-13 04:49:31.736429+00
a26e6532-552d-46c1-b3da-a3af6e35be0a	3924e217-b079-4dfb-9bda-070bbf392626	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:26.805734+00	\N	\N	staff	4	52	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:48:26.806979+00	2025-06-13 04:48:26.805734+00
c4a68e1e-850d-4554-9dcc-77d91c2dce59	bb9d87e3-73fa-42ee-a28e-b33d87ae758b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:26.805734+00	\N	\N	bow	4	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:48:26.806979+00	2025-06-13 04:48:26.805734+00
cbed93c2-3e44-415e-9628-ba81b42eda56	86d0474d-ee20-43eb-83a7-f035aaac83b6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:26.805734+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-14 06:48:26.806979+00	2025-06-13 04:48:26.805734+00
251bd013-f478-47a3-be21-3075428f04a8	dd8c8835-caf4-4b6b-a43a-ce9ee285cabd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:50:26.891965+00	\N	\N	staff	13	113	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 18:50:26.893805+00	2025-06-13 04:50:26.891965+00
3414012a-e83d-4cf4-9b57-6bd124eebd8b	3bb72e3d-4093-4e14-b911-c8a70d5f1394	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:50:26.891965+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:50:26.893805+00	2025-06-13 04:50:26.891965+00
a90c0ae2-22ea-4f89-a4e0-40e46b4446d1	7b22c169-b0eb-4c8b-a3f7-ed5915698110	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:50:26.891965+00	\N	\N	hammer	5	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:50:26.893805+00	2025-06-13 04:50:26.891965+00
5695bf55-a990-4e63-8853-812af29a02a6	3721e938-79f9-404f-9b70-95bdc299181c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:56.80669+00	\N	\N	dagger	6	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 10:48:56.807914+00	2025-06-13 04:48:56.80669+00
efee8171-39ae-4e66-a522-0dc70e73cabc	e49ef9ac-c3f3-4656-ac5e-9f0ccb457f02	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:56.80669+00	\N	\N	sword	3	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:48:56.807914+00	2025-06-13 04:48:56.80669+00
e44c09d4-0b02-4f16-95a5-c0320df4f40a	547b6719-2795-4424-afa7-9743b6450b51	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:48:56.80669+00	\N	\N	dagger	19	285	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 11:48:56.807914+00	2025-06-13 04:48:56.80669+00
1d842227-10cf-4d8d-8e42-3b9bb411f944	f35ff5f6-e917-4c70-b301-9c457f5a68b9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:56.785477+00	\N	\N	sword	7	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:49:56.786285+00	2025-06-13 04:49:56.785477+00
31f938f1-45d3-4baa-9c57-f2e64f343f8c	cf2d4fb4-a5f2-46c5-ab73-cc494b6dab98	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:56.785477+00	\N	\N	sword	4	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:49:56.786285+00	2025-06-13 04:49:56.785477+00
d359f480-4422-4390-9e92-b4c36dfba45e	13056346-246b-4333-84ca-e18939a6c9a0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:56.785477+00	\N	\N	staff	3	52	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:49:56.786285+00	2025-06-13 04:49:56.785477+00
5057293c-e450-488b-8651-10e38e5fc160	f66631c7-7a6b-4da3-9186-601a9aac9369	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:56.785477+00	\N	\N	sword	7	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:49:56.786285+00	2025-06-13 04:49:56.785477+00
8c171e2a-78e1-4772-a5c2-381050b2ba4c	a3d9042c-1d7a-4103-8ca6-c69c1ee2146b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:49:56.785477+00	\N	\N	dagger	5	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:49:56.786285+00	2025-06-13 04:49:56.785477+00
00d2552c-1ba4-416b-a3bb-25ac161d32b1	18a4fdd8-6da6-4f98-8025-bf698a105028	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:10.395299+00	\N	\N	hammer	5	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:51:10.401331+00	2025-06-13 04:51:10.395299+00
354d482a-c265-4548-a0fc-832d2fd3a920	bf2e3ce7-306b-41fd-9a57-57f2073ea00e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:10.395299+00	\N	\N	dagger	6	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:51:10.401331+00	2025-06-13 04:51:10.395299+00
285e8be3-a15e-4aac-9122-17074065683f	539b03a4-8ad3-44b7-9db5-f0c34958ca55	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:10.395299+00	\N	\N	sword	20	220	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 14:51:10.401331+00	2025-06-13 04:51:10.395299+00
3879e45c-9d2b-476b-b7dc-68363d9ccf11	5450de7b-9624-4d8e-a47e-df0504c18a3d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:10.395299+00	\N	\N	staff	7	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:51:10.401331+00	2025-06-13 04:51:10.395299+00
33271b99-cf39-4bac-8632-fb8103d272c1	9b36f42f-19c5-4772-8537-94482db0dd43	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:10.395299+00	\N	\N	bow	7	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:51:10.401331+00	2025-06-13 04:51:10.395299+00
96ed7817-2400-41b9-a5ed-b3b2276336e5	b74cb702-5a38-4572-8933-57bb30194960	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:11.847328+00	\N	\N	hammer	4	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 09:51:11.85104+00	2025-06-13 04:51:11.847328+00
a822dc92-f232-45d5-87f5-03db48417e7d	8b4fcd81-c0eb-423c-8651-d9999bf1659d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:11.847328+00	\N	\N	sword	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:51:11.85104+00	2025-06-13 04:51:11.847328+00
0133f090-b37f-4206-8b9a-103ebe96165c	e7427b26-7e39-4988-8bc5-30558112b2f7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:27.366818+00	\N	\N	sword	3	66	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:51:27.36838+00	2025-06-13 04:51:27.366818+00
c6695a7a-edd7-425f-a531-5a803d12ba55	54d53d04-e6f2-473b-84b0-44631631c9f7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:27.366818+00	\N	\N	dagger	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:51:27.36838+00	2025-06-13 04:51:27.366818+00
ebaaf651-f432-4376-a4a5-9c0ee6a5f609	fea8e6c1-b79a-422f-a206-7c8f8397c367	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:56.97432+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:51:56.975588+00	2025-06-13 04:51:56.97432+00
3edb620d-e43f-4103-afd3-91a2c58ee14a	b40c894b-5174-4d47-a77a-e3379d131b82	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:56.97432+00	\N	\N	dagger	3	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:51:56.975588+00	2025-06-13 04:51:56.97432+00
52d38823-2f6f-4f7c-ae11-36ee33f7adae	507d1d6b-5baf-482e-b415-f4ca8ea52d7e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:59.911178+00	\N	\N	bow	7	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:51:59.912503+00	2025-06-13 04:51:59.911178+00
2c4905c6-6c71-4d87-b86d-49f27c5f9825	dde4a4d2-ec0d-49f4-ba96-dd177e77106f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:59.911178+00	\N	\N	bow	13	195	common	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 07:51:59.912503+00	2025-06-13 04:51:59.911178+00
3a1a18b5-4d2a-46e2-8551-3fe1e1d694df	363453cd-92eb-4b94-b56f-0cd3e19c5c48	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:51:59.911178+00	\N	\N	bow	3	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:51:59.912503+00	2025-06-13 04:51:59.911178+00
0329c011-e439-4582-8180-205ffe175e70	d96350e6-983e-47ad-ba8b-188127797bf9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:26.822321+00	\N	\N	bow	5	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:52:26.823185+00	2025-06-13 04:52:26.822321+00
801566c7-6570-48cc-8845-17a0745b02bd	c19601bc-e6c8-4537-8782-8b4b0328cdfb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:26.822321+00	\N	\N	bow	7	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:52:26.823185+00	2025-06-13 04:52:26.822321+00
fd0e9b1c-fcbd-45f7-ab2b-2a758b8db9bc	5041a910-abd9-46dd-ab2c-1b97da5a889b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:26.822321+00	\N	\N	sword	14	154	rare	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 18:52:26.823185+00	2025-06-13 04:52:26.822321+00
6f9f25d0-f9ca-4430-bbbc-0d734b1a21e8	f4218b0a-cd36-40d4-b927-ca7464a97e67	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:56.882292+00	\N	\N	staff	3	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:52:56.883319+00	2025-06-13 04:52:56.882292+00
ce92ccbf-3456-409b-8c08-b7a0756ac010	88f08ec9-16e6-4a0c-ba02-2189e5b4d269	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:56.882292+00	\N	\N	staff	5	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:52:56.883319+00	2025-06-13 04:52:56.882292+00
5bc3d722-68c1-4a0d-bb02-33542deb2bae	3a1a0062-3653-4c08-a168-4f4857174755	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:52:56.882292+00	\N	\N	hammer	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:52:56.883319+00	2025-06-13 04:52:56.882292+00
a9387071-c756-42a9-b8e6-a91225cdc3e3	77859666-74cf-4bba-a862-062dc1047e31	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:14.015444+00	\N	\N	hammer	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:53:14.016603+00	2025-06-13 04:53:14.015444+00
7e5b6d83-e994-4b11-b11d-6b9c0cd44cb5	0d2e8488-1651-4e68-800e-edda70fee5b1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:14.015444+00	\N	\N	sword	7	66	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:53:14.016603+00	2025-06-13 04:53:14.015444+00
c961833a-31db-41e5-b786-479f4c72b512	685e7c60-9586-44a6-afe0-e11a4643c754	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:14.015444+00	\N	\N	dagger	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 07:53:14.016603+00	2025-06-13 04:53:14.015444+00
12f6403d-4480-4362-ac2b-ad5b2332e0f8	09fd3599-fef7-4945-9dc6-28331895f1ea	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:14.015444+00	\N	\N	bow	20	300	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 04:53:14.016603+00	2025-06-13 04:53:14.015444+00
346ccb9f-7779-4480-9476-baf5a1a6ad5e	504ab010-6684-4152-90b0-bbbb686426f8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:14.015444+00	\N	\N	staff	7	52	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:53:14.016603+00	2025-06-13 04:53:14.015444+00
01f2fc9b-72e5-49e9-87f8-30c9f8c2a3b6	5bf31770-17ba-4edc-9e9e-8e01ac338322	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:26.829076+00	\N	\N	dagger	16	240	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 10:53:26.830394+00	2025-06-13 04:53:26.829076+00
6b65a5ad-4627-493d-901a-46bdd452a616	06bde693-8029-4cca-9c82-58977a123c2c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:26.829076+00	\N	\N	staff	4	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:53:26.830394+00	2025-06-13 04:53:26.829076+00
20bc71d1-7c90-4236-91b8-6a6b17433dd1	d12e7a8b-d739-4b51-8920-fd5c6031bce8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:26.829076+00	\N	\N	staff	7	52	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:53:26.830394+00	2025-06-13 04:53:26.829076+00
bcd69c48-13d9-40d5-b1b0-3d5d8fbb6f72	6942d91c-2362-46fe-a566-a7df514d5ac8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:56.837783+00	\N	\N	dagger	4	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:53:56.838805+00	2025-06-13 04:53:56.837783+00
65bcc28a-8fba-48b2-be4d-9a3ae9d276b6	06c3ad4e-d663-4657-ac9b-bddc53340afc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:53:56.837783+00	\N	\N	sword	19	209	common	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 21:53:56.838805+00	2025-06-13 04:53:56.837783+00
0ab2b683-2c79-4b3a-803a-f8a25bd3f4f1	d54d91f7-8ac8-4b37-9f21-93c71bc2c09a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:26.851885+00	\N	\N	staff	15	131	epic	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 07:54:26.853251+00	2025-06-13 04:54:26.851885+00
71f4311c-7c1b-444f-b0ca-f86e43f5580d	063c453e-e4b2-4d26-a6a5-81d78d414e36	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:26.851885+00	\N	\N	hammer	5	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:54:26.853251+00	2025-06-13 04:54:26.851885+00
d6edcfa9-a286-41b0-8739-219edcf85670	916a01b9-6dc0-403a-ac16-47fee3046686	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:26.851885+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:54:26.853251+00	2025-06-13 04:54:26.851885+00
1397b590-82ca-46d6-867f-53ef689b6c90	8c56caaf-f5c2-46a3-9666-52bfc3e90b9c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:26.851885+00	\N	\N	bow	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 08:54:26.853251+00	2025-06-13 04:54:26.851885+00
a7807229-8d87-43db-8e6e-5c20b081ea4b	019c4c09-d7c1-4c17-80ac-809fecd1050d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:56.80998+00	\N	\N	dagger	5	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 07:54:56.810949+00	2025-06-13 04:54:56.80998+00
74e43032-60e3-4c41-9bda-becc00889da2	7fc30bef-ec04-4a67-80b8-f3d8930cab4e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:56.80998+00	\N	\N	staff	19	166	epic	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 12:54:56.810949+00	2025-06-13 04:54:56.80998+00
ddd792be-2e57-4635-bb28-db60b9ff1a64	c12d37f3-c849-4004-982a-0fb72bb6ab10	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:56.80998+00	\N	\N	hammer	5	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:54:56.810949+00	2025-06-13 04:54:56.80998+00
e69bb1c1-bbd7-4bd8-a4ea-5a38164da238	a1fbd70f-bfa8-40cc-8db9-2c2f1a0fd4e4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:56.80998+00	\N	\N	sword	5	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:54:56.810949+00	2025-06-13 04:54:56.80998+00
ebac712e-3df6-4c7b-8599-7ee316e09227	5e880af4-e8bf-42f8-aa82-576f065f72a4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:54:56.80998+00	\N	\N	dagger	14	210	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 16:54:56.810949+00	2025-06-13 04:54:56.80998+00
eee2f256-4a9b-49f1-928a-e722da9a2666	05d07317-8eae-46e4-8eec-5bf6aff34d7a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:12.078182+00	\N	\N	dagger	3	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:55:12.079794+00	2025-06-13 04:55:12.078182+00
de9f98e4-3677-47ac-8ae4-c02cadf4f696	03a126c3-5d5a-4bf6-94c0-21d4e36c7d98	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:12.078182+00	\N	\N	sword	6	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:55:12.079794+00	2025-06-13 04:55:12.078182+00
81822767-230d-4db6-a18d-9a9dbe1575d6	cb57b5b0-977f-402b-bf3d-9d1d3adcd4ad	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:12.078182+00	\N	\N	sword	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:55:12.079794+00	2025-06-13 04:55:12.078182+00
ddf9d830-9742-44cd-a71e-0cc971a95b48	84bbb001-754a-4f6c-b23a-693f0b560f2d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:12.078182+00	\N	\N	hammer	6	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 09:55:12.079794+00	2025-06-13 04:55:12.078182+00
83371fc5-229d-4819-9ee8-f0820ba81a1b	ae17d814-bd02-47df-9f51-15b4ee4f6137	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:26.818952+00	\N	\N	sword	3	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:55:26.819638+00	2025-06-13 04:55:26.818952+00
e0e219f1-05aa-42c5-b58b-bb48cfd2f110	520ace75-7cb7-4dea-aaaf-a77ec889ad60	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:26.818952+00	\N	\N	sword	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:55:26.819638+00	2025-06-13 04:55:26.818952+00
065e2250-9384-4713-8ba9-eb91a1559111	1e03be91-11ab-490e-9135-3820c20c2b10	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:26.818952+00	\N	\N	staff	3	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:55:26.819638+00	2025-06-13 04:55:26.818952+00
52bb293f-d1b0-4a73-aa32-441a82cdf771	42d9eea7-8484-4d75-adb8-406573e3b83e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:51.352009+00	\N	\N	hammer	16	176	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 10:57:51.353342+00	2025-06-13 04:57:51.352009+00
d70de735-5301-4aee-93aa-0b01f872feaa	a2b910bb-ff95-4091-b450-b254d1e9db14	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:51.352009+00	\N	\N	bow	4	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:57:51.353342+00	2025-06-13 04:57:51.352009+00
ff0909ea-0f6e-42a2-9fd0-da33d496bfae	53cf9465-025c-4c4c-b381-96417b970db1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:00.44464+00	\N	\N	sword	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:58:00.447085+00	2025-06-13 04:58:00.44464+00
1620c316-d34f-476b-a6f7-31f293f0d4b4	e4a331d6-2802-408c-aa09-d564cb27a204	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:00.44464+00	\N	\N	staff	17	148	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:58:00.447085+00	2025-06-13 04:58:00.44464+00
ffa34456-b388-4d1b-8870-710fa4c27ab8	c4a47cf9-0163-4b8a-8be9-eb2e72fa4d2f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:00.44464+00	\N	\N	dagger	3	90	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:58:00.447085+00	2025-06-13 04:58:00.44464+00
04e7c9a2-d5ee-40e5-88d7-a26f7c418600	1e0c0885-cbc5-47c7-8e63-ecfe4a15275b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:00.44464+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:58:00.447085+00	2025-06-13 04:58:00.44464+00
1e81ff14-471a-4e2a-8589-91bb1bfbad62	c4855da8-9b48-4514-9a51-fcb44c9db4dd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:30.149939+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:58:30.150931+00	2025-06-13 04:58:30.149939+00
a889c78c-8d72-4aed-9cf4-3b285097d2be	4e9206b0-57ba-4597-9a56-dd17151d0d18	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:30.149939+00	\N	\N	staff	5	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:58:30.150931+00	2025-06-13 04:58:30.149939+00
73941e27-54c9-48d7-af5d-532bd3bf8dc1	8cef6bc7-d0d9-4595-87bb-864f4bcbb66c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:30.149939+00	\N	\N	dagger	3	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:58:30.150931+00	2025-06-13 04:58:30.149939+00
8482bf8b-9fdb-437a-a443-dec037ee95e6	24f4923f-5ed5-468d-935c-9202ce6af5f6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:58:30.149939+00	\N	\N	hammer	4	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:58:30.150931+00	2025-06-13 04:58:30.149939+00
323755ff-7e52-4ffe-8ee5-3096c3c46800	1aa25888-8b29-4963-8e8a-fb38450ce593	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:30.176389+00	\N	\N	bow	19	285	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 11:00:30.177153+00	2025-06-13 05:00:30.176389+00
844cec93-8f07-4e17-8210-9ed6a638ce90	1d4b883d-ad76-4624-b05a-d86931f0f744	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:30.176389+00	\N	\N	sword	4	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:00:30.177153+00	2025-06-13 05:00:30.176389+00
398b7fb0-2a5b-4a5d-ac13-9d91b4ee9299	99b4f287-a530-4bba-a290-cdba9d3e9cde	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:25.083778+00	\N	\N	hammer	14	154	common	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 14:01:25.085534+00	2025-06-13 05:01:25.083778+00
68f0be93-440e-411f-975d-ba1dcf198552	a11e3a7c-e832-446e-800a-c72d8244958a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:25.083778+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:01:25.085534+00	2025-06-13 05:01:25.083778+00
1c822d66-a563-4148-8f66-ebc2f7fd5285	f265d120-bb11-48ea-ad93-798ee911fee6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:25.083778+00	\N	\N	staff	3	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:01:25.085534+00	2025-06-13 05:01:25.083778+00
7f6487fc-e243-4ef2-aa24-a424040b0032	5ac153fc-5d77-44d4-8bd0-c29a16ce0e2c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:25.083778+00	\N	\N	bow	5	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:01:25.085534+00	2025-06-13 05:01:25.083778+00
20616299-6891-4917-b008-9b2b62f40b21	21277967-bef5-4528-9393-4f0ec9f26200	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:25.083778+00	\N	\N	hammer	3	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:01:25.085534+00	2025-06-13 05:01:25.083778+00
c84ee2bc-bbe7-4c37-993d-e21c16868257	651148f5-7c9e-45b9-b1ce-b4cd2c99b4c5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:56.793142+00	\N	\N	bow	20	300	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:55:56.794491+00	2025-06-13 04:55:56.793142+00
9baea618-e7ed-4ce5-b9e7-6c6f15fd1eef	1188eb30-429d-4f76-9434-0c7ae4b5913e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:56.793142+00	\N	\N	bow	7	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:55:56.794491+00	2025-06-13 04:55:56.793142+00
3ff136c2-2268-40ea-93e6-1e120d87511c	2e2de494-2c21-42f9-8be9-85606059574d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:55:56.793142+00	\N	\N	bow	6	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:55:56.794491+00	2025-06-13 04:55:56.793142+00
0bab4ad4-39a6-4e59-8062-7120b8c172cb	3fc7c083-bd0e-4eef-9b47-eb53b226bf6c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:56:26.800857+00	\N	\N	hammer	20	220	epic	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 19:56:26.801643+00	2025-06-13 04:56:26.800857+00
df09542b-582f-40aa-adb4-2de204dcd349	93d5fccc-7aa4-4e39-98e4-3be2c903ffac	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:56:26.800857+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:56:26.801643+00	2025-06-13 04:56:26.800857+00
634d1e5c-845d-46db-86c0-9eb6e73b92bf	2bfbe795-e845-4ed9-ade5-373a2c680959	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:56:26.800857+00	\N	\N	dagger	3	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:56:26.801643+00	2025-06-13 04:56:26.800857+00
b6b0c7fb-4f3d-4663-b388-a8a49ee64757	3121a00d-cbaf-4836-aec2-e0a16fbf6490	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:14.548658+00	\N	\N	sword	7	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 14:57:14.550928+00	2025-06-13 04:57:14.548658+00
7a47b214-99bc-424f-b682-4c90b02db760	df744345-702a-4065-ba28-cce077960614	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:14.548658+00	\N	\N	staff	3	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:57:14.550928+00	2025-06-13 04:57:14.548658+00
f7df09fc-55b5-49dc-8f3a-e7cb84ef42f3	e1dda3e4-92b0-466b-a6ce-314596e7a5f9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:14.548658+00	\N	\N	bow	7	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:57:14.550928+00	2025-06-13 04:57:14.548658+00
3336d055-5f1c-4de5-bbc5-8e16ee7eaf9a	3ebdfcc6-b98a-4fe4-9928-fc963ea1f951	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:14.548658+00	\N	\N	dagger	3	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 12:57:14.550928+00	2025-06-13 04:57:14.548658+00
e3adff3a-a8ec-4bef-b562-340d684a45ee	5252ad39-3539-466b-b873-ae4e0aef5f6b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:14.548658+00	\N	\N	sword	6	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:57:14.550928+00	2025-06-13 04:57:14.548658+00
44f8a295-6e30-4d4b-9934-dbe12d09b438	969afd0a-c9c7-434c-82c2-48b29ab4396d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:21.44335+00	\N	\N	staff	5	52	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 09:57:21.445047+00	2025-06-13 04:57:21.44335+00
d12fb206-f46d-4885-8879-e43289752413	75d4f853-6485-4940-a557-727635c78b67	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:57:21.44335+00	\N	\N	staff	5	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:57:21.445047+00	2025-06-13 04:57:21.44335+00
ff64c2c3-cc7c-4048-8a44-b90e864a67ba	70f063e9-d7bc-427b-9b4c-4cdf2c3cd22d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:00.34537+00	\N	\N	bow	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:59:00.346603+00	2025-06-13 04:59:00.34537+00
553a8e8c-1739-4d2d-9bf2-86a74528022a	ce2edae4-ea03-405d-b607-c18f303a74fd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:00.34537+00	\N	\N	hammer	5	66	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 13:59:00.346603+00	2025-06-13 04:59:00.34537+00
4b809c42-61e1-4b18-b4ae-479dd4e9b4b4	4d3c0b5b-a166-40cc-a4c1-307ee0d6f82e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:30.218581+00	\N	\N	hammer	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 07:59:30.219773+00	2025-06-13 04:59:30.218581+00
17b8b9be-6faa-49c2-a3aa-dfaa4d639334	99e12b36-1086-42f7-beaa-fbdb7a989650	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:30.218581+00	\N	\N	hammer	3	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:59:30.219773+00	2025-06-13 04:59:30.218581+00
9cf86d31-b5c3-4304-9741-633248ca7c06	bd86a936-b2d6-43f9-bb8a-18a87de53129	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:30.218581+00	\N	\N	dagger	5	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:59:30.219773+00	2025-06-13 04:59:30.218581+00
d40a81cd-3e8e-4bf2-a86a-9d350fcfdf72	6e0bc0c4-559a-4399-88de-d5abf1b64591	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:00.3118+00	\N	\N	bow	6	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:00:00.312457+00	2025-06-13 05:00:00.3118+00
9793664c-f038-463f-b53d-c77ebee8b6ab	5214f944-9fe2-43d9-80d7-29e49f97c0fe	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:00.3118+00	\N	\N	sword	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:00:00.312457+00	2025-06-13 05:00:00.3118+00
2ea17a0d-483b-4a7d-ada2-c7664c52475b	7ac8399c-62c3-4776-93a2-13243a11025c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:00.3118+00	\N	\N	staff	14	122	rare	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 00:00:00.312457+00	2025-06-13 05:00:00.3118+00
216f4c74-16f3-44ee-a9fa-bf110f18d258	760701ff-5dba-4e9c-a999-4a4948a6294c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:00.3118+00	\N	\N	sword	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:00:00.312457+00	2025-06-13 05:00:00.3118+00
10721fa6-3a5c-4104-9c73-ac62f15af92c	71ca2dc8-de93-477c-96ec-38d9dc097c60	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:32.034318+00	\N	\N	hammer	7	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:00:32.035506+00	2025-06-13 05:00:32.034318+00
eebb5641-67dc-4250-8ebd-eb997c5b546b	22609406-60d0-4b21-bb79-46b8a700dc14	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:32.034318+00	\N	\N	sword	3	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:00:32.035506+00	2025-06-13 05:00:32.034318+00
e109e0cd-103d-4a13-8742-d278376f8939	13ae1443-b6c6-4091-85f0-dac1aa1f639c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:00:32.034318+00	\N	\N	sword	15	165	epic	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 09:00:32.035506+00	2025-06-13 05:00:32.034318+00
76196885-770a-4539-aa14-381d1e1d0475	5efb5843-3f1b-4baa-aa00-ffe7684c77e9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:00.371059+00	\N	\N	hammer	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:01:00.371779+00	2025-06-13 05:01:00.371059+00
d0e35cb9-cc58-4f7e-b60f-76e9123cbfb1	e40fd473-4b63-4e18-b4bf-960645a25807	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:00.371059+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:01:00.371779+00	2025-06-13 05:01:00.371059+00
4d4ee235-d6ba-4f62-96c5-bedca051bc2d	ad524b1b-3292-4983-9987-b7f9684c5c6a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:30.189023+00	\N	\N	staff	5	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 14:01:30.190236+00	2025-06-13 05:01:30.189023+00
2c132a19-d489-4cf1-9771-619e8f31f97c	ee97a37f-340b-491f-b442-298f32a34b0f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:01:30.189023+00	\N	\N	bow	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:01:30.190236+00	2025-06-13 05:01:30.189023+00
c28f4f7e-021b-488e-ae34-103888ee0cbb	7cab8f83-856a-4811-8428-f8928c1770c0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:00.26837+00	\N	\N	dagger	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:02:00.269472+00	2025-06-13 05:02:00.26837+00
ee4bc108-6a8d-4b77-b556-5655db6ce419	8a4d27cb-9394-4632-9ccc-0e92f7395df9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:00.26837+00	\N	\N	dagger	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:02:00.269472+00	2025-06-13 05:02:00.26837+00
b0e6802b-cad3-46fa-901b-57f7e01eacf1	62d2417d-ac9b-4091-bea3-e4b0086ddb1a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:00.26837+00	\N	\N	dagger	19	285	rare	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:02:00.269472+00	2025-06-13 05:02:00.26837+00
3e751b6f-9d1f-44ee-8647-c13c492ed485	6b1c80a3-dd01-4045-9968-854f94814a54	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:00.26837+00	\N	\N	hammer	3	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:02:00.269472+00	2025-06-13 05:02:00.26837+00
bd6405af-f8ce-4b47-8309-50c0867088f8	dcbbc89f-d2b0-4bc5-ac33-b4aef06f86c2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:00.26837+00	\N	\N	sword	19	209	rare	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 01:02:00.269472+00	2025-06-13 05:02:00.26837+00
c6836caa-94de-4e7b-b0b1-195b22a9b0a0	d0720624-0e0e-428a-bbf8-dbf751b2aee6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:20.963008+00	\N	\N	sword	6	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:59:20.964137+00	2025-06-13 04:59:20.963008+00
17fe821c-34d7-4fd9-b2b6-b929795d1b17	efe072eb-9782-4469-adef-27f59d601ba2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:20.963008+00	\N	\N	bow	15	225	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 16:59:20.964137+00	2025-06-13 04:59:20.963008+00
77f58d97-cfe1-4c56-91db-1834a6d3be6a	cb8273eb-bd99-457b-b8cd-cfb3c542b874	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:20.963008+00	\N	\N	dagger	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:59:20.964137+00	2025-06-13 04:59:20.963008+00
88c97e3f-c793-420c-8a9d-7fdbedc2cede	d5a5685c-06c2-41e7-90c6-13973e49cc9e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 04:59:20.963008+00	\N	\N	dagger	3	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 09:59:20.964137+00	2025-06-13 04:59:20.963008+00
35ed9da5-b79f-46e5-9598-6e7267791bda	30d3f4d7-fc19-47dd-88e4-03e74eeeeaa4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:30.198296+00	\N	\N	staff	3	52	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 10:02:30.199614+00	2025-06-13 05:02:30.198296+00
873b30d4-5999-4601-9610-2496dbc1f52e	0b34a32d-f19a-4813-93a6-6dcf1e30ffec	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:30.198296+00	\N	\N	dagger	15	225	epic	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 08:02:30.199614+00	2025-06-13 05:02:30.198296+00
65924130-ecd9-4cff-b117-384feb21b5ce	b1c861c9-db74-4c72-867f-222d5d6b0790	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:30.198296+00	\N	\N	staff	18	157	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 22:02:30.199614+00	2025-06-13 05:02:30.198296+00
b294ed78-afad-4ff0-b905-a0cd3fcbc1ea	f6029198-1e35-465f-af2a-2bb9096b366d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:53.161042+00	\N	\N	sword	3	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:02:53.162478+00	2025-06-13 05:02:53.161042+00
cbd24dc3-70b7-4117-b3be-9d4acb84b202	46c651bb-5143-4faa-a969-90681163a285	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:53.161042+00	\N	\N	staff	14	122	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 17:02:53.162478+00	2025-06-13 05:02:53.161042+00
be09b21f-7fa0-4b97-a2ce-dbf06c06ae7f	1de2e7d2-a4bd-4851-a786-585d70b0ad65	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:02:53.161042+00	\N	\N	bow	6	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:02:53.162478+00	2025-06-13 05:02:53.161042+00
032cbded-dcd9-426b-b9e2-d0e8b3e3d2cd	8c344a58-98d1-4639-960d-b00a17d40561	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:03:00.234697+00	\N	\N	sword	4	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:03:00.235481+00	2025-06-13 05:03:00.234697+00
63579eb3-c3b9-46e7-9d3b-f5e8700c4e87	177685b0-ddb1-46ca-a059-56221e442601	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:03:00.234697+00	\N	\N	staff	3	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:03:00.235481+00	2025-06-13 05:03:00.234697+00
b57ce39c-8f03-4848-98be-5fce3d18874f	7572f28a-f4be-453c-a89a-efb188968924	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:03:30.144763+00	\N	\N	staff	13	113	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 11:03:30.145715+00	2025-06-13 05:03:30.144763+00
162e5752-cac6-4fd8-ac38-2fd803985449	ab723116-d6a6-453b-995c-355a6fbb57fd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:03:30.144763+00	\N	\N	hammer	3	66	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:03:30.145715+00	2025-06-13 05:03:30.144763+00
ff855cb1-c739-4997-a8e6-51d468c6eb73	2ccf1e82-7772-4fd9-9566-4752d52a835e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:00.263613+00	\N	\N	staff	5	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:04:00.264792+00	2025-06-13 05:04:00.263613+00
bfb7a9fa-b37c-4952-b85d-6acaec226e35	a62ee508-ef78-4829-b011-b72c2aaf72be	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:00.263613+00	\N	\N	dagger	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:04:00.264792+00	2025-06-13 05:04:00.263613+00
9e33dc2d-cf89-4e6d-b62a-929168c6cba3	67e06bb2-9d75-4a1b-9c86-3da2991f946b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:00.263613+00	\N	\N	sword	6	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:04:00.264792+00	2025-06-13 05:04:00.263613+00
2bba658e-9351-436c-9acb-db7bd8c2b276	5a6ccdd7-fc99-4621-ba4e-7faa4669ee34	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:00.263613+00	\N	\N	hammer	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:04:00.264792+00	2025-06-13 05:04:00.263613+00
12ad05cb-be22-4125-8ecc-c395e8b5f11a	9d068301-4576-4e29-bec4-d60318f6c392	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:18.201764+00	\N	\N	staff	3	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:04:18.202753+00	2025-06-13 05:04:18.201764+00
06c7bd47-0700-4422-a976-5cb8d3c69e03	01b60648-c842-44c3-bdac-c1ec17aedd21	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:18.201764+00	\N	\N	sword	13	143	common	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 23:04:18.202753+00	2025-06-13 05:04:18.201764+00
0a904244-ad28-4376-bfd9-f85a9befbbc5	2b861e39-fb5e-419a-a77d-9129d83abd5c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:18.201764+00	\N	\N	sword	3	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:04:18.202753+00	2025-06-13 05:04:18.201764+00
b4f077a7-d6d9-4426-9f2b-74aaf390cc3c	a97a5f08-9a38-40ed-af5c-162658da0c20	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:30.181117+00	\N	\N	staff	3	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:04:30.181903+00	2025-06-13 05:04:30.181117+00
eee0447c-d25a-4eb5-9bc0-cce308d8f0ba	ec042231-a0cd-48a0-a913-6c7fcd450782	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:30.181117+00	\N	\N	dagger	15	225	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 13:04:30.181903+00	2025-06-13 05:04:30.181117+00
a276c2dd-e4cd-41b2-a033-fc88d7426aa7	b0fa40b6-db18-4818-b709-2f8cb5923fe5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:30.181117+00	\N	\N	sword	18	198	common	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 09:04:30.181903+00	2025-06-13 05:04:30.181117+00
99d75d14-5a6e-48cc-a001-221106f31ffa	ae7c7254-6ca4-47dd-adc4-75385bda5762	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:04:30.181117+00	\N	\N	dagger	7	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:04:30.181903+00	2025-06-13 05:04:30.181117+00
e1d15150-61c9-4188-8f47-aaa1997a259f	b6e411d0-f791-4974-947c-4cf0a98eb9e1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:05:00.301456+00	\N	\N	staff	5	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 12:05:00.302584+00	2025-06-13 05:05:00.301456+00
e8db0634-446a-45d3-8386-cb1a11b5eee3	cebff189-3afe-4e91-9cca-03b7487aa824	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:05:00.301456+00	\N	\N	bow	6	90	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:05:00.302584+00	2025-06-13 05:05:00.301456+00
5916ff06-8010-4368-9836-0810b5c531a3	89dc776b-37b7-4a2c-8d6d-e156616c6858	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:05:30.18382+00	\N	\N	dagger	6	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 14:05:30.184691+00	2025-06-13 05:05:30.18382+00
cb6e6b75-82b9-46e9-95e3-06da79161f57	9c22c3b9-9dd8-4cbb-98ae-390be6907426	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:05:30.18382+00	\N	\N	sword	5	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 17:05:30.184691+00	2025-06-13 05:05:30.18382+00
85e29e89-b06b-4ac7-b045-611491a0cd08	0367e575-a25e-4d8d-9d00-875a5a0882c8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:26.916631+00	\N	\N	sword	4	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:06:26.918898+00	2025-06-13 05:06:26.916631+00
b9315a26-3acb-4dea-ab81-0f2b5bdc35cc	057c315d-519f-4999-be3a-bae21e4478f8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:26.916631+00	\N	\N	sword	3	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:06:26.918898+00	2025-06-13 05:06:26.916631+00
82bbaab3-d380-47e7-b457-49b130dfd73a	3c7754ec-958d-4174-9de5-bdcd01662660	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:26.916631+00	\N	\N	hammer	7	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:06:26.918898+00	2025-06-13 05:06:26.916631+00
05c6d7a3-f097-4641-87c7-c0b711c32fe1	ed16603e-1681-4075-bf18-8587176db69d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:31.121091+00	\N	\N	bow	7	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:06:31.123426+00	2025-06-13 05:06:31.121091+00
0a827b7a-e9c8-4b14-a220-18a535d1191a	0290f90b-2528-4233-96b7-b66d2d721db9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:31.121091+00	\N	\N	hammer	7	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:06:31.123426+00	2025-06-13 05:06:31.121091+00
5b7a2de7-6d21-4fe0-9ad8-f865c6a9458b	1136f3f1-1e88-44d1-af18-163cc09bebb0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:54.441897+00	\N	\N	dagger	4	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:06:54.443572+00	2025-06-13 05:06:54.441897+00
28e0cae0-f214-43ee-8314-69ef1e61bbd4	a82eef07-4ec8-4be8-9f3e-ce65decc0312	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:54.441897+00	\N	\N	dagger	3	90	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:06:54.443572+00	2025-06-13 05:06:54.441897+00
73455643-7af5-4d43-8826-779c5dc9e2a5	247fd06e-0d22-4e64-ab43-468b211fd118	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:54.441897+00	\N	\N	bow	7	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 13:06:54.443572+00	2025-06-13 05:06:54.441897+00
22fa3f8a-2b5f-4a58-9de5-cc24ad87899b	5585b615-d41a-4b91-97f9-ad4a55145cfa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:54.441897+00	\N	\N	staff	7	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:06:54.443572+00	2025-06-13 05:06:54.441897+00
1f9d1116-7be0-47c7-ad00-78678488109f	2e2889f9-c7db-4d5e-bd97-d3a632be4fd0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:06:54.441897+00	\N	\N	staff	7	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:06:54.443572+00	2025-06-13 05:06:54.441897+00
7c399405-a7a4-422c-b599-18d0b0833ba1	9820a4a0-bfe9-4604-a2fc-0353787b223c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:24.332606+00	\N	\N	bow	7	90	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:07:24.333308+00	2025-06-13 05:07:24.332606+00
fc82d1e9-1cdb-4e56-94af-020f7638856a	b1e4a423-2963-4915-91cd-b3ffbf513d6f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:24.332606+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:07:24.333308+00	2025-06-13 05:07:24.332606+00
d4ea5242-f075-435e-8d2c-dc4282df1eec	719e9338-d622-488f-bc6f-7d41c57a330c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:54.365278+00	\N	\N	staff	6	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:07:54.366465+00	2025-06-13 05:07:54.365278+00
4fc60c4f-9328-4537-bdc2-2ebb7d8ea118	3f116bd9-57f7-4ac9-abf7-bcb37b71910a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:54.365278+00	\N	\N	staff	5	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 10:07:54.366465+00	2025-06-13 05:07:54.365278+00
e18b012e-d56b-4a5b-9c3d-c7decf0b855f	7466b808-bf80-4be6-b142-4096ac5682e1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:54.365278+00	\N	\N	sword	4	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:07:54.366465+00	2025-06-13 05:07:54.365278+00
38e38b53-ee67-4873-998f-22ab90b3f8b5	86c9fcf8-fc34-4545-9ebd-416405b9b6f0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:54.365278+00	\N	\N	hammer	7	66	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 10:07:54.366465+00	2025-06-13 05:07:54.365278+00
fcd9b755-f5a9-4b2e-b3ff-08c71eb770ed	d1087931-9650-4bbe-b23b-e8458bca49c9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:54.365278+00	\N	\N	bow	7	90	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 12:07:54.366465+00	2025-06-13 05:07:54.365278+00
1b21eb72-4248-42eb-90a9-de248ac9f69a	190513b7-990b-4ba4-b901-9d90a72e48e3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:24.33886+00	\N	\N	bow	17	255	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 12:08:24.340013+00	2025-06-13 05:08:24.33886+00
75ce0874-7456-48bf-a0ee-a63f44338483	03113887-a403-4b55-8ca2-d16cecccc7ef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:24.33886+00	\N	\N	dagger	4	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:08:24.340013+00	2025-06-13 05:08:24.33886+00
37393999-3c03-4d46-af45-397759e1c143	ee180145-d226-4a8c-90f3-662d0131c95e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:44.165117+00	\N	\N	bow	5	90	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 12:07:44.166188+00	2025-06-13 05:07:44.165117+00
625a5af5-3795-4ce2-a32a-f13564087fc0	fe80cf2e-71cb-4292-80f9-4307272deb8d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:44.165117+00	\N	\N	sword	3	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:07:44.166188+00	2025-06-13 05:07:44.165117+00
19e2c92e-a152-4b00-a95d-cc7e12cd87c1	0c09f139-6284-4b62-97fc-583fd24ae598	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:44.165117+00	\N	\N	sword	6	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:07:44.166188+00	2025-06-13 05:07:44.165117+00
d6505830-7f27-484f-b33b-4146bf55c2ea	960e5f56-9155-437f-8e87-ee256a601431	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:44.165117+00	\N	\N	sword	7	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:07:44.166188+00	2025-06-13 05:07:44.165117+00
219c2198-d233-4098-bd83-20de88019e45	1b802c09-2601-47ee-b475-97f08faa2c80	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:07:44.165117+00	\N	\N	sword	19	209	rare	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 21:07:44.166188+00	2025-06-13 05:07:44.165117+00
bb1de9e1-1d30-4cf2-8e4d-481d7451dae8	9310301c-a71c-4d61-9644-8e0d967f9bfd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:54.359833+00	\N	\N	bow	5	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:08:54.36113+00	2025-06-13 05:08:54.359833+00
bf5d26fe-7798-4ffa-bc75-b6a9135b89fb	573bc898-28a0-46e4-8e3d-451241b0a595	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:54.359833+00	\N	\N	sword	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:08:54.36113+00	2025-06-13 05:08:54.359833+00
288b744c-36bd-4bf7-93be-31f22813f910	6f46ab9c-6492-4fcc-8465-8f6b02ad5147	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:54.359833+00	\N	\N	dagger	6	90	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:08:54.36113+00	2025-06-13 05:08:54.359833+00
5ea756d5-69ea-4776-8e7b-61f7ffe129d1	cb8eb2b0-130e-4e85-8e0a-4180614938c1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:54.359833+00	\N	\N	hammer	15	165	epic	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 19:08:54.36113+00	2025-06-13 05:08:54.359833+00
b94b5ad8-d0c0-4714-9afb-8082cc620cf1	60b13aa2-03ef-4ca5-befe-64f2a6ab5de5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:08:54.359833+00	\N	\N	dagger	4	90	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:08:54.36113+00	2025-06-13 05:08:54.359833+00
cc26a23d-b014-487e-b7eb-7a4953c8be69	9bdec817-b7b7-4c80-b2cd-fd06213835ae	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:31.22088+00	\N	\N	bow	14	210	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 14:09:31.222406+00	2025-06-13 05:09:31.22088+00
6c826ff0-4351-4f65-aea1-2b329629b7e3	668d991e-4223-49bd-8604-5aa6e8fb3259	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:31.22088+00	\N	\N	hammer	17	187	common	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 15:09:31.222406+00	2025-06-13 05:09:31.22088+00
9a05a73b-3994-4837-9011-1d9a6ad5fe50	b15ecf9f-3f88-407e-992d-35cca4c38423	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:24.374207+00	\N	\N	hammer	6	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:09:24.374938+00	2025-06-13 05:09:24.374207+00
277dbfea-1873-4515-a4cc-ea8cf5d74bf8	220101bb-2135-4805-9483-a5eb2c03f359	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:24.374207+00	\N	\N	sword	18	198	rare	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 23:09:24.374938+00	2025-06-13 05:09:24.374207+00
8035ceee-466c-431e-ab6d-bc3bedeed929	9456cb9a-3100-4416-b3a8-ef9edf5cf262	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:54.325067+00	\N	\N	hammer	6	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 11:09:54.325898+00	2025-06-13 05:09:54.325067+00
c1dba8dd-c2b0-49d8-9e03-d4e2b6d60ff7	ac2fbc87-5d26-486e-bfdd-f9df05c44557	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:54.325067+00	\N	\N	staff	7	52	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 10:09:54.325898+00	2025-06-13 05:09:54.325067+00
9a91362c-0dd0-4df3-b467-3fb0ed6cb974	a746cab2-b5bf-4525-99fd-e56cab02ad8f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:54.325067+00	\N	\N	staff	3	52	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:09:54.325898+00	2025-06-13 05:09:54.325067+00
dde35f53-a0fb-45a9-bd8f-84d9ef7e3f53	7ffc5643-0c0e-438f-955c-0de30d639226	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:54.325067+00	\N	\N	staff	3	52	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 08:09:54.325898+00	2025-06-13 05:09:54.325067+00
e03669b2-90b5-4456-9025-9f0763532e1b	2d788bd1-2eb8-40e7-8d28-ceba9d867b39	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:09:54.325067+00	\N	\N	staff	5	52	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:09:54.325898+00	2025-06-13 05:09:54.325067+00
e2b7c8c8-817d-4e22-b1ec-cff41aff6524	86eb298b-43ee-49df-974e-e30f3e757534	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.513912+00	\N	\N	hammer	7	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:35:06.579978+00	2025-06-13 05:35:06.513912+00
2e2757fa-e79c-492d-82f7-30cad4e2f00a	0c8b757a-e059-4f86-bfe8-93fc1a26eaf8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.513912+00	\N	\N	bow	4	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:35:06.579978+00	2025-06-13 05:35:06.513912+00
5ee9d038-83f2-4784-88ba-04e848505893	62418e9d-8e5e-47c9-a3df-0016fcdd2d0a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.674812+00	\N	\N	bow	3	90	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 08:35:06.739136+00	2025-06-13 05:35:06.674812+00
b4ae0510-e698-4dbe-91dd-ddfe233ca450	116ed19c-f03c-49bf-9799-b8a4ab637f0d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.715226+00	\N	\N	sword	4	66	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:35:06.774114+00	2025-06-13 05:35:06.715226+00
232e03a2-1b5d-4977-808e-9434579cb3dc	4172a863-32fa-4436-a1e3-8e6f703ba8be	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.674812+00	\N	\N	bow	6	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:35:06.739136+00	2025-06-13 05:35:06.674812+00
3bef41e8-3a3c-4162-9016-d59051a2281f	07fbc2e6-c74b-4fee-a253-588ace21785c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.715226+00	\N	\N	dagger	3	90	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:35:06.774114+00	2025-06-13 05:35:06.715226+00
777715b6-7347-4e24-ab1d-1c923040bede	ac53f46b-9b01-4b38-b868-b0c2c655b0e1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.674812+00	\N	\N	staff	4	52	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:35:06.739136+00	2025-06-13 05:35:06.674812+00
220b19ae-5c6c-4a53-8ff3-66865cf9922f	48f57109-ad01-4e11-b2a0-749fb630f468	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.715226+00	\N	\N	hammer	7	66	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 17:35:06.774114+00	2025-06-13 05:35:06.715226+00
68dc6690-d501-44c1-af74-4648e67188cb	09c7677b-451f-4990-af5a-2b5b2873f062	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.715226+00	\N	\N	sword	16	176	epic	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 16:35:06.774114+00	2025-06-13 05:35:06.715226+00
0350d39a-f1ba-462e-9e08-72d2e345760b	e9ee9d7f-0002-4e6b-8197-4cf2c5cff9dc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.858032+00	\N	\N	sword	5	66	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 12:35:06.941461+00	2025-06-13 05:35:06.858032+00
61437272-97c4-45ff-9909-e847b98cc645	b27fc4d9-6ce2-4cbc-9596-45d6a9ab7113	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.858032+00	\N	\N	hammer	6	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:35:06.941461+00	2025-06-13 05:35:06.858032+00
51668932-e32b-415c-a8b1-02180d4820fb	c6c92024-a194-49ec-899b-66449d7cd6fc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:07.089694+00	\N	\N	bow	5	90	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:35:07.102321+00	2025-06-13 05:35:07.089694+00
29bf77cc-3a09-4145-8434-6d9d8fb90a42	c5902bc7-e251-425f-800f-1fabce8edbb5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.858032+00	\N	\N	hammer	7	66	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 18:35:06.941461+00	2025-06-13 05:35:06.858032+00
a9e25143-d993-4507-ab50-7ec17b74f664	1ddec3c4-0e11-44d2-8e20-c3f509b03cd7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:07.089694+00	\N	\N	staff	5	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 13:35:07.102321+00	2025-06-13 05:35:07.089694+00
715ad292-7813-407e-a6ff-f5d47ef1c69b	31133de0-eff1-4fec-aff8-4b264d1c8b2d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:06.858032+00	\N	\N	staff	5	52	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 11:35:06.941461+00	2025-06-13 05:35:06.858032+00
6f93a59d-0612-462b-8d60-10fe7175b7c9	9b27816b-3589-45b2-aeb0-0d042b383517	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:22.976128+00	\N	\N	staff	4	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:35:22.979073+00	2025-06-13 05:35:22.976128+00
ad81de24-e8c4-48e2-b846-5c8620228509	4226735d-60dd-43d9-87c1-19202202eb8b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:22.976128+00	\N	\N	dagger	4	90	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:35:22.979073+00	2025-06-13 05:35:22.976128+00
6751d849-669a-4bf4-8b90-47581f59a0a6	fdde2d0c-98fb-498f-a11c-cf98509c9b79	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:22.976128+00	\N	\N	sword	4	66	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:35:22.979073+00	2025-06-13 05:35:22.976128+00
b709bcd0-926c-4f5a-b4a0-fd227e3e95f0	d6337509-165a-421f-9f49-c07c39ebe54f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 05:35:22.976128+00	\N	\N	hammer	6	66	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 08:35:22.979073+00	2025-06-13 05:35:22.976128+00
7a384bdb-ee23-47e9-b52d-80007ea94071	ac499199-ec34-4b1b-91b9-1481d4a117c6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:04:14.23512+00	\N	\N	staff	13	75	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:04:14.236518+00	2025-06-13 08:04:14.23512+00
bb85a8c7-49d2-4f46-98f7-8c2cff5b9ae8	520ce486-f4d5-48c5-a66e-f9dbe73d820c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:04:14.23512+00	\N	\N	bow	12	120	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:04:14.236518+00	2025-06-13 08:04:14.23512+00
35273e40-3593-4944-abd2-b39285e73021	b0ec7fbe-c8be-488c-b790-36017e75ff2b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:04:14.23512+00	\N	\N	hammer	15	110	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 08:04:14.236518+00	2025-06-13 08:04:14.23512+00
5608c07f-342b-41ef-b59a-ebe0f9ed4d8b	d4b7b184-c132-4b33-82e0-34cdafb9cc3a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:04:14.23512+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:04:14.236518+00	2025-06-13 08:04:14.23512+00
ac61b159-169d-4549-912f-a1b15cd73d54	2064b96b-2d62-4eb8-9231-295143bf4f84	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:11:10.333827+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-15 07:11:10.335292+00	2025-06-13 08:11:10.333827+00
92de3f84-38c5-405e-84bd-afe71c50b958	8b247dae-8d98-4142-8cbf-147bef461785	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:11:10.333827+00	\N	\N	staff	15	87	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 11:11:10.335292+00	2025-06-13 08:11:10.333827+00
bbf797e1-9f57-4d97-b5a5-56891d817709	9ab2ff7d-f79a-4e5a-a98c-f778f7380862	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:16:30.954058+00	\N	\N	hammer	5	66	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 17:16:30.955296+00	2025-06-13 08:16:30.954058+00
d63bf541-cb72-4515-819e-e9cc31f51a99	9349e2a4-bf5a-42ab-86fc-fc86fabe3d91	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:16:30.954058+00	\N	\N	bow	7	90	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:16:30.955296+00	2025-06-13 08:16:30.954058+00
94477725-af34-4093-bee9-1271626cc595	2c506b7a-3327-444e-ae92-88c167b48fa3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:16:30.954058+00	\N	\N	sword	7	66	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 06:16:30.955296+00	2025-06-13 08:16:30.954058+00
8ff4e36f-d96c-4c1c-ac70-6cdf2f279ece	c5c150e3-f7e0-46cd-a496-4405ba300fcc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:16:30.954058+00	\N	\N	staff	7	52	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:16:30.955296+00	2025-06-13 08:16:30.954058+00
fe7555c0-e9f9-4895-8d27-ad408383c461	035a6fef-87ab-4e2c-aafb-dc1bbd079df6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:19:40.113094+00	\N	\N	hammer	15	110	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:19:40.138044+00	2025-06-13 08:19:40.113094+00
db7c4b3f-adc8-4184-98c2-27301c5e3cd4	27957315-4650-4449-be63-012bd7575878	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:19:40.113094+00	\N	\N	staff	12	70	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:19:40.138044+00	2025-06-13 08:19:40.113094+00
efac8807-6c0b-48e9-b5c5-4f9010eefb96	cee2745a-25db-4eeb-8e78-5fd8371b421c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:19:40.113094+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 11:19:40.138044+00	2025-06-13 08:19:40.113094+00
c336325d-79f1-42df-94e9-c2608c572dee	e37d6870-9031-4c20-9e1d-7c3cb0efc6bf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:19:40.113094+00	\N	\N	bow	27	405	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:19:40.138044+00	2025-06-13 08:19:40.113094+00
05f0046a-97c0-4d23-95f3-c0895cd5184f	9250a22d-3668-4b83-99c0-1a94cf713bee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:34:15.667983+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:34:15.669682+00	2025-06-13 08:34:15.667983+00
56f7048a-f968-466b-8ae4-a1805701c73e	d6185d55-4be1-469d-b458-5d06915fa539	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:34:15.667983+00	\N	\N	dagger	12	120	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:34:15.669682+00	2025-06-13 08:34:15.667983+00
183cae6a-ed5f-43c0-b4a2-55de22e13547	bd6b5cb7-72b6-4a25-a2dd-395646a0eb9e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:35:29.71657+00	\N	\N	bow	13	130	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:35:29.717718+00	2025-06-13 08:35:29.71657+00
630ca5e9-d500-4ac3-843e-e8f74b4aea79	b01c133e-1d4d-4a8b-b008-32b35c07c041	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:35:29.71657+00	\N	\N	bow	14	140	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:35:29.717718+00	2025-06-13 08:35:29.71657+00
4cbd0d67-efff-48f0-9b0c-c0008031d925	d7bd5cb0-30dc-4277-9609-f35423f30895	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:56:58.750388+00	\N	\N	staff	12	70	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:56:58.752823+00	2025-06-13 08:56:58.750388+00
c6c6a2e8-548e-4f73-bc9a-83072bff9339	01843b9a-b868-4c72-8293-8d9f30a58e8c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:56:58.750388+00	\N	\N	bow	14	140	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:56:58.752823+00	2025-06-13 08:56:58.750388+00
5b47bfa9-d3b4-41b6-878c-8a19707a8721	ea1eb86c-d2af-47af-9157-6d6bea988242	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:56:58.750388+00	\N	\N	sword	12	88	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:56:58.752823+00	2025-06-13 08:56:58.750388+00
a222d5ca-591d-43c0-ae96-f39094efabe2	c2bbe5d3-e990-4fca-bb36-82be89f7fb51	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:56:58.750388+00	\N	\N	hammer	27	297	rare	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 02:56:58.752823+00	2025-06-13 08:56:58.750388+00
9a87c69b-d27d-4e1a-ab92-f2575d3f12b5	0d3a2570-e60a-4d14-bf69-a94d14c8e39c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 08:56:58.750388+00	\N	\N	staff	11	64	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:56:58.752823+00	2025-06-13 08:56:58.750388+00
fce69314-0096-4fa6-b279-98d437d5f32e	20335aa0-89fd-4a6b-967c-77d75257a1bc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 09:20:50.327132+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-14 08:20:50.328286+00	2025-06-13 09:20:50.327132+00
801dc18c-7fcf-43aa-81b4-4935c05dbf88	f078e42d-cf14-43d7-96eb-4b7a7493e39e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 09:20:50.327132+00	\N	\N	bow	12	120	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:20:50.328286+00	2025-06-13 09:20:50.327132+00
642d6c63-695b-4d17-843b-a89b3fd2e0f9	64891789-1c95-41d9-bbf6-7ee104eb5b1d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 09:20:50.327132+00	\N	\N	bow	21	315	epic	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 21:20:50.328286+00	2025-06-13 09:20:50.327132+00
daf7517e-71a0-4995-905b-0684983bbf02	ef4e2721-37a0-4102-9bfe-322a845babe8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:27:15.255418+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-14 00:27:15.25749+00	2025-06-13 12:27:15.255418+00
cf1b6ab9-ba50-4e8c-8c66-75ea83bdd1a2	2bd33839-9d42-48e7-9289-84a76f505c34	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:27:15.255418+00	\N	\N	dagger	13	130	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:27:15.25749+00	2025-06-13 12:27:15.255418+00
d3a34111-439a-4517-bf75-184d9d2a1004	1fd172c5-68f1-4b7d-9bb1-19f25c4e33c4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:27:15.255418+00	\N	\N	sword	12	88	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:27:15.25749+00	2025-06-13 12:27:15.255418+00
a80902b1-ad10-49de-9c9b-94532254805b	408324c3-3986-4a1e-a243-1fa68894c5bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:27:15.255418+00	\N	\N	hammer	11	80	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 08:27:15.25749+00	2025-06-13 12:27:15.255418+00
3c8bf1f5-1d63-4524-a075-e8677567ae95	a67ed1c4-446a-4786-8973-7b9490c6f0e5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:28:57.094355+00	\N	\N	staff	11	64	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:28:57.095414+00	2025-06-13 12:28:57.094355+00
3d0ede4b-0334-45ea-aa2b-0a231003b3c2	8e6db9cb-98f2-43d1-95b4-7c94c8fffeed	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:28:57.094355+00	\N	\N	staff	14	81	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:28:57.095414+00	2025-06-13 12:28:57.094355+00
ed5b5ac8-4357-4091-b4fe-efb41ca689d7	d4c85ab6-9eb2-4966-a1fa-6ce1406557ee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:28:57.094355+00	\N	\N	bow	12	120	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:28:57.095414+00	2025-06-13 12:28:57.094355+00
c2b1acd5-05de-4a0a-bd42-e2f92a02a0c4	1a27a0bb-fcc5-4f88-a2bb-7bf3e889fd9b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:29:55.031613+00	\N	\N	staff	12	70	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:29:55.047056+00	2025-06-13 12:29:55.031613+00
e04895ff-dbdd-4db8-8e1f-5321c967d67f	16ac560c-9d61-4f02-97c4-b34b6d5a7e3a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:29:55.031613+00	\N	\N	staff	25	218	common	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 10:29:55.047056+00	2025-06-13 12:29:55.031613+00
3a13c6f2-e738-4996-94ee-242541eaa9a0	893281e4-29ab-4530-9443-51d14cd65469	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:29:55.031613+00	\N	\N	sword	14	102	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 07:29:55.047056+00	2025-06-13 12:29:55.031613+00
1f153462-4b38-43fc-bf27-a4703748bcdc	ac768838-0d1a-49f2-a337-d1dbe8a1f2ec	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:29:55.031613+00	\N	\N	staff	13	75	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:29:55.047056+00	2025-06-13 12:29:55.031613+00
545fc481-d4b9-497d-994a-88b188c48c30	27496489-4a5c-4010-b13c-fd20b0da3745	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:29:55.031613+00	\N	\N	sword	14	102	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 21:29:55.047056+00	2025-06-13 12:29:55.031613+00
c9316f03-54e1-40d2-b703-0d9f7440dfc4	4f8bcff3-8d5d-4915-bb4a-be6aeb6b6cb7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:46:11.2618+00	\N	\N	bow	14	140	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:46:11.266069+00	2025-06-13 12:46:11.2618+00
917feaf8-3a3d-4b9f-91b4-b58a5305f732	74580b3e-d9c3-408a-bd04-3040d350aa35	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:46:11.2618+00	\N	\N	staff	15	87	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:46:11.266069+00	2025-06-13 12:46:11.2618+00
d537317e-70d2-4b82-8acc-cd75d112d114	0a069536-fe31-436e-b275-9f1bf7b7883f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:46:11.2618+00	\N	\N	dagger	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:46:11.266069+00	2025-06-13 12:46:11.2618+00
b383d89f-fa6c-4ae0-86d5-261cbf5eb939	0ed92a3f-29a3-495f-85f6-3b8a1d06332c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:46:41.335668+00	\N	\N	dagger	12	120	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:46:41.336906+00	2025-06-13 12:46:41.335668+00
001c805a-99a2-4344-8f63-f995b552e3a7	cd44e9cc-a7c4-40a7-be45-b8fe1d60994a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:11.097182+00	\N	\N	sword	15	110	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:47:11.101039+00	2025-06-13 12:47:11.097182+00
2aa7f23d-7512-46fb-95b2-662cd4ab1c11	777cef0d-2fbd-4031-b077-316c55c30957	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:11.097182+00	\N	\N	staff	11	64	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:47:11.101039+00	2025-06-13 12:47:11.097182+00
a7a30fb5-22fc-4683-8de8-df1f495c0a87	cd510238-c665-404b-a273-fbd3ec6dead3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:16.119502+00	\N	\N	hammer	14	102	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:47:16.120903+00	2025-06-13 12:47:16.119502+00
97faf711-1688-44cf-b400-3b6d8035c1ae	015ed509-fc4d-489c-8b62-2915280c74f7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:16.119502+00	\N	\N	bow	13	130	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:47:16.120903+00	2025-06-13 12:47:16.119502+00
18ba7792-8c58-4e7d-aa81-c2c6be6f87cb	aefa9ad7-bb9f-4df5-a947-cfe1a8bacd06	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:16.119502+00	\N	\N	sword	13	95	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:47:16.120903+00	2025-06-13 12:47:16.119502+00
e96fb383-7db7-41a5-8f70-fa635092307b	06bab10c-90f6-4ae2-865b-dea9bc39ecd5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:40.642037+00	\N	\N	staff	14	81	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:47:40.644495+00	2025-06-13 12:47:40.642037+00
c5f2a551-5c23-488f-8a92-bcae3b993def	137a308b-e5f2-4b3a-8278-bf1698127f9b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:40.642037+00	\N	\N	hammer	25	275	epic	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 15:47:40.644495+00	2025-06-13 12:47:40.642037+00
dc102452-993b-4147-8326-5a0ebdbca0f3	943220bf-7443-44eb-b88e-2d0081320d98	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:47:40.642037+00	\N	\N	sword	13	95	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 07:47:40.644495+00	2025-06-13 12:47:40.642037+00
5744874c-bccd-461d-b11d-333dd614a0e8	ea9ccbc1-a59c-4e16-a149-3838066d9dba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:10.580255+00	\N	\N	bow	14	140	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:48:10.583247+00	2025-06-13 12:48:10.580255+00
23833058-35d4-4ec7-8c41-293c2a3fbc76	eaa016ba-aff1-43b4-92dc-018c55af3475	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:10.580255+00	\N	\N	staff	11	64	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:48:10.583247+00	2025-06-13 12:48:10.580255+00
18de0e59-836a-4280-ac1e-4564df91f8ed	72f96a09-a4dc-40d3-8489-4257ef9d6bb0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:40.577422+00	\N	\N	staff	27	236	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 10:48:40.579047+00	2025-06-13 12:48:40.577422+00
da7e1627-be74-41f0-947d-09426f44a625	41d377ee-0199-4cca-89d3-062c50cf6d98	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:40.577422+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:48:40.579047+00	2025-06-13 12:48:40.577422+00
c9516cfd-8b40-456c-858b-4b0f2159eedc	9638aeed-851d-4d19-9f9b-d2a83f4008c0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:44.184436+00	\N	\N	staff	14	81	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:48:44.186067+00	2025-06-13 12:48:44.184436+00
404f5973-53d2-45d5-a791-327776712b73	f73291ee-a5f5-4785-a4df-3b7bbf355ad6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:48:44.184436+00	\N	\N	dagger	15	150	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:48:44.186067+00	2025-06-13 12:48:44.184436+00
eb63f049-7feb-439a-93d5-b64c8e14011d	df48a735-b958-428e-8ebf-43f702732180	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:40.610782+00	\N	\N	staff	14	81	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:49:40.6127+00	2025-06-13 12:49:40.610782+00
6651af14-5854-4396-bdbc-7320303d24c7	46511a27-797d-477c-abac-8182a161cb17	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:40.610782+00	\N	\N	sword	15	110	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 04:49:40.6127+00	2025-06-13 12:49:40.610782+00
ab8f240f-db89-4aa0-9534-71fc7b896eab	e157b69f-da65-4b40-860e-a04cc32170c9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:50:40.386042+00	\N	\N	dagger	14	140	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:50:40.387405+00	2025-06-13 12:50:40.386042+00
f215c741-d2a3-4fcf-a5e9-63cac45f19bd	2ed3b47e-8955-4d21-b1fc-4e527229f361	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:10.553962+00	\N	\N	bow	13	130	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:49:10.555674+00	2025-06-13 12:49:10.553962+00
99c1ea5c-57cc-43be-8ab0-6fe0117ada6f	72067c14-d61e-4bd9-8c09-ae9c9912c1e5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:10.553962+00	\N	\N	hammer	22	242	common	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 06:49:10.555674+00	2025-06-13 12:49:10.553962+00
11a09461-92c0-4dd1-8b3f-4bbb53b33c96	7ed87991-5af7-45fa-9ca0-35a771e644d3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:10.553962+00	\N	\N	dagger	23	345	epic	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 19:49:10.555674+00	2025-06-13 12:49:10.553962+00
b24b2b72-db7d-4101-af7d-60a0ec973407	12825776-e59c-4e6e-b051-2becb0379f45	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:33.241344+00	\N	\N	hammer	11	80	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:49:33.24275+00	2025-06-13 12:49:33.241344+00
371530d1-291f-4782-ade1-ff1cc6c11d5c	b8ae6145-b456-4f4a-8d17-9e9a1a1398c1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:33.241344+00	\N	\N	bow	12	120	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:49:33.24275+00	2025-06-13 12:49:33.241344+00
1822c8fe-de1a-4256-94a4-e647389dd395	f2856490-8501-4884-bf1f-3a5740cda082	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:49:33.241344+00	\N	\N	bow	14	140	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:49:33.24275+00	2025-06-13 12:49:33.241344+00
310764b4-fb87-43d0-a8aa-d124fa15c428	a60c3a7b-1f11-4a96-9eac-363d66810db8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:40.629673+00	\N	\N	dagger	12	120	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:51:40.631241+00	2025-06-13 12:51:40.629673+00
d300e778-d4eb-4750-8d38-5093b3a8c2fd	15844451-93cf-4dfb-aa20-2e316576b565	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:40.629673+00	\N	\N	sword	11	80	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:51:40.631241+00	2025-06-13 12:51:40.629673+00
6702783c-b306-49c8-b25b-05ddd5436948	d77bf6c8-ae6d-44dd-b8aa-51b8a9854fb4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:40.629673+00	\N	\N	sword	13	95	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:51:40.631241+00	2025-06-13 12:51:40.629673+00
1bbcc71d-0986-4929-af3a-b1f90141017d	37e0c8fd-c736-4a34-b597-c8be6c2b65de	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:50:10.541282+00	\N	\N	hammer	14	102	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:50:10.54232+00	2025-06-13 12:50:10.541282+00
38145aeb-8096-4912-a04f-22d0ab89159c	679c3eca-caeb-4c54-9f08-65b1d8c1eda9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:50:10.541282+00	\N	\N	staff	13	75	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:50:10.54232+00	2025-06-13 12:50:10.541282+00
50cb81b6-f16e-4e1c-8a77-aa246209b72b	551e13a5-b032-4691-990f-b8d22b9bcfbb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:10.570874+00	\N	\N	dagger	13	130	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:51:10.572122+00	2025-06-13 12:51:10.570874+00
5c4149aa-41ce-4c18-8ea2-5d53440efb1d	597437fd-6d37-4a3e-abbd-87f10abffa68	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:10.570874+00	\N	\N	bow	24	360	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:51:10.572122+00	2025-06-13 12:51:10.570874+00
0e849800-b9b8-44d4-a918-12a68da79284	bee9456e-085b-4876-8300-ad04b9d80d89	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:10.570874+00	\N	\N	staff	12	70	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:51:10.572122+00	2025-06-13 12:51:10.570874+00
6da88e8a-f618-47b4-8777-608ea7215206	e74fc2a7-bd2f-481a-8100-a1ed8e58e325	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:51:26.327632+00	\N	\N	bow	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:51:26.329351+00	2025-06-13 12:51:26.327632+00
0bf066c7-faf4-4248-98c2-62fa1ec0cf2e	4f4b70ca-456e-484a-aa09-4c08b9eba7d6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:11.065238+00	\N	\N	hammer	13	95	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 17:52:11.070486+00	2025-06-13 12:52:11.065238+00
b789c67c-eac2-4d9f-906d-e2bfbc443364	662ee057-1179-4db0-99ee-91622c56c1f5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:11.065238+00	\N	\N	staff	13	75	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:52:11.070486+00	2025-06-13 12:52:11.065238+00
8b9252a4-fc57-4f9d-81b5-9e658fb21d8c	ca20f35f-30ee-4847-8996-b04f93420a7f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:15.359465+00	\N	\N	sword	23	253	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 23:52:15.360825+00	2025-06-13 12:52:15.359465+00
5fdcbbdd-24e1-4a5f-bc72-626ca6be3bad	0bfb4a8b-8567-4191-b940-01cd1042d5d0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:40.283532+00	\N	\N	staff	11	64	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:52:40.284622+00	2025-06-13 12:52:40.283532+00
56202e3e-d033-41c6-b6d7-c616d55009cd	ccbeb08e-615b-42ad-ab3c-a73b9118bc31	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:40.283532+00	\N	\N	staff	11	64	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:52:40.284622+00	2025-06-13 12:52:40.283532+00
de6f0ab0-f1e5-42b8-9598-4bf135b8adb0	f6d19e7b-03f1-47ac-ab87-daee55e92d03	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:52:40.283532+00	\N	\N	dagger	22	329	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 10:52:40.284622+00	2025-06-13 12:52:40.283532+00
b4501e95-73c5-40f4-bcac-f19da43a5258	6a389444-3837-4487-8bcb-53511c2f6bcc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:53:10.282045+00	\N	\N	hammer	14	102	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 09:53:10.282817+00	2025-06-13 12:53:10.282045+00
ffbbc45d-18e7-4b89-91b0-9da9c917b9e9	6cedcf94-8f8f-422d-9502-ca3760389b35	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:53:10.282045+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:53:10.282817+00	2025-06-13 12:53:10.282045+00
710892be-3269-46aa-83be-8cbacd0a727f	0e319c29-1d8e-424b-93d9-e529e90c5d7c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:53:45.537933+00	\N	\N	sword	11	80	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 10:53:45.539778+00	2025-06-13 12:53:45.537933+00
bddf85fc-351a-44dc-b462-70fee896de53	17e31039-8b29-4603-bf24-cf08d962b8f2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:53:45.537933+00	\N	\N	sword	11	80	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:53:45.539778+00	2025-06-13 12:53:45.537933+00
f5277379-61d2-47af-8c48-56d05a9c1221	64d46c36-4988-4b92-b213-51321279303b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:54:15.414153+00	\N	\N	staff	22	192	epic	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 16:54:15.414908+00	2025-06-13 12:54:15.414153+00
444e1347-2434-4023-a335-56dd62082796	0244a5b2-4534-4daf-b94a-dff197621446	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:54:45.444036+00	\N	\N	sword	13	95	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:54:45.444987+00	2025-06-13 12:54:45.444036+00
4f470faa-063b-45aa-b6b8-3da294913eb5	890bb019-eefe-4bc2-9be1-0d6265dfeb91	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:54:45.444036+00	\N	\N	bow	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:54:45.444987+00	2025-06-13 12:54:45.444036+00
6e79f280-c270-4c0b-9da7-1aff3f9f0aab	fb240520-97a6-452d-ab20-d24f4ba0dda5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:54:45.444036+00	\N	\N	dagger	12	120	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:54:45.444987+00	2025-06-13 12:54:45.444036+00
0ac2b400-16f7-4b43-97c9-82245731e77a	92bf9c98-e423-4c3e-878b-212da145f567	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:55:04.206173+00	\N	\N	hammer	12	88	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:55:04.207244+00	2025-06-13 12:55:04.206173+00
83bc9103-6896-4dfd-9ddc-d8950657fc19	8dc6b5ae-fa8e-464d-b2d1-afaaf393453a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:55:15.502017+00	\N	\N	staff	12	70	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:55:15.502896+00	2025-06-13 12:55:15.502017+00
2bebded6-16e7-44ed-8168-45dda11716c7	701ecfe4-8bd6-4ab0-ba1b-4a07f73aeb4f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:55:15.502017+00	\N	\N	staff	23	201	epic	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 22:55:15.502896+00	2025-06-13 12:55:15.502017+00
601df68d-466c-427e-a97b-f09710cb67a1	1d9c3d68-c7e5-487d-ade6-31f8c61e2ba0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:55:45.461435+00	\N	\N	sword	13	95	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 12:55:45.462315+00	2025-06-13 12:55:45.461435+00
dcd1441b-1c06-411f-8ebb-704b46e52b71	347d1bac-dd78-4ad0-8b84-07b49c71a940	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:55:45.461435+00	\N	\N	bow	11	109	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:55:45.462315+00	2025-06-13 12:55:45.461435+00
0ae30fe1-c80e-4d17-804c-bbd0a087efde	c09f183d-9230-4175-a574-0a5f51b9631a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:09.237548+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:56:09.239154+00	2025-06-13 12:56:09.237548+00
2a980aaa-8b5b-404f-9201-5003d1c5ffa8	0de32543-11ad-4303-a545-40cd38f9c5f9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:09.237548+00	\N	\N	staff	11	64	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 15:56:09.239154+00	2025-06-13 12:56:09.237548+00
13771b45-0c02-46f8-9b2a-f622e0bc6fc6	ee631444-eec0-4f23-b4c1-2e027dba1e86	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:15.483747+00	\N	\N	bow	13	130	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:56:15.484833+00	2025-06-13 12:56:15.483747+00
a8ad629b-ba54-4ad9-b189-aaa5bf45cecf	a971ff36-8d0e-4797-b6d2-aeb8ee819db4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:45.404495+00	\N	\N	dagger	12	120	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:56:45.406151+00	2025-06-13 12:56:45.404495+00
55537d42-71cc-4893-a3f0-2bbfb0f8b40f	d18555fe-7091-45ae-90a4-63591e869d0c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:45.404495+00	\N	\N	staff	11	64	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:56:45.406151+00	2025-06-13 12:56:45.404495+00
0a25a1e6-2392-465e-88cf-c7b018cc059e	6663c4a7-a7ee-485f-92f2-d0173c0a4cef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:56:45.404495+00	\N	\N	staff	12	70	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:56:45.406151+00	2025-06-13 12:56:45.404495+00
7fd1dd6e-8266-4891-904a-8c7d802c23fd	18800a2f-3a2f-4fb7-8a12-bc3c7ccd473d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:02.467022+00	\N	\N	bow	15	150	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 15:57:02.469567+00	2025-06-13 12:57:02.467022+00
c6b891e4-3669-4182-8dcc-ea0fecc767ae	22500371-d0e6-4451-a515-2183836815f7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:02.467022+00	\N	\N	bow	13	130	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:57:02.469567+00	2025-06-13 12:57:02.467022+00
45f716d6-b11e-408f-9077-3a0b1eb8af59	f6621cf7-fd0a-42ca-bee1-5afc33f7a884	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:15.782307+00	\N	\N	dagger	27	405	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 21:57:15.783962+00	2025-06-13 12:57:15.782307+00
143bb433-b325-4bbd-b73a-3d839666cc35	47abc637-60bd-4507-a43e-2019980ea983	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:45.468351+00	\N	\N	sword	60	3500	common	3	【固有】見習い冒険者 アリスからの特別なリクエスト	2025-06-14 21:57:45.469854+00	2025-06-13 12:57:45.468351+00
ab97d98f-ee37-46a9-8f84-fe32f27b2d92	a25fa313-685f-4f58-a62e-2dba00264d54	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:45.468351+00	\N	\N	sword	15	110	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 11:57:45.469854+00	2025-06-13 12:57:45.468351+00
a2f0692a-c4bb-4525-8004-52f8f81f3d89	f9d3d4b2-e599-4f86-8a47-0f9ac919c8a4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:45.468351+00	\N	\N	sword	15	110	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:57:45.469854+00	2025-06-13 12:57:45.468351+00
da56eda7-e70e-4d79-87bf-fece668572ca	f7991335-354e-4321-b63b-054f95d056bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:54.521229+00	\N	\N	bow	15	150	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:57:54.523004+00	2025-06-13 12:57:54.521229+00
9215c891-d440-46d6-85a9-048e6c367c72	36ce6a20-4bb1-4794-9f8e-00bad1bf8754	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:57:54.521229+00	\N	\N	dagger	12	120	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:57:54.523004+00	2025-06-13 12:57:54.521229+00
8bdb83d0-f072-4315-b4ca-34c80d458dfd	35f7548a-0ed7-4b16-b80d-ead60ae42e27	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:58:16.049353+00	\N	\N	hammer	14	102	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:58:16.05024+00	2025-06-13 12:58:16.049353+00
2e6e13fe-fd43-439c-9a09-8185f534dfd6	b49a5162-0a1d-4c99-b023-a3e9c82c993c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:58:16.049353+00	\N	\N	staff	23	201	epic	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 07:58:16.05024+00	2025-06-13 12:58:16.049353+00
54e7aeb3-4023-41eb-9d61-61445847e460	86e6b096-eea9-410c-849f-1cee81f66fde	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:58:16.049353+00	\N	\N	sword	13	95	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:58:16.05024+00	2025-06-13 12:58:16.049353+00
e6bb2446-ff12-430e-96c9-9ea457481016	510cf527-3940-4e21-82c6-d3e2256a3746	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:05.579221+00	\N	\N	staff	14	81	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:59:05.580604+00	2025-06-13 12:59:05.579221+00
6cac43e0-9225-46a3-a782-fa50f48c35ac	e1563cf9-185d-45b5-a349-7c817e2278f7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:05.579221+00	\N	\N	staff	12	70	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:59:05.580604+00	2025-06-13 12:59:05.579221+00
28d3dfe7-5db5-48e1-8546-2a41148b94b7	51c053e8-64fc-4b69-8e25-2bf01a62b4f6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:05.579221+00	\N	\N	sword	14	102	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 15:59:05.580604+00	2025-06-13 12:59:05.579221+00
935b4405-3e59-47a3-805d-3b971d340cd3	3115b563-ad4e-4eb4-a7e4-b99eea0a80f2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:15.818257+00	\N	\N	sword	11	80	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 11:59:15.819488+00	2025-06-13 12:59:15.818257+00
24a179dc-b339-4b89-b6b4-b629cd0e1a97	62ed7d8e-a26c-4656-a6e3-11ffe56150a0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:15.818257+00	\N	\N	dagger	14	140	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:59:15.819488+00	2025-06-13 12:59:15.818257+00
c2829f0f-4dca-4b7d-b749-0754fef76f53	05505e0c-05b7-45ed-86fd-fbbe2698ece5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:15.818257+00	\N	\N	sword	11	80	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 19:59:15.819488+00	2025-06-13 12:59:15.818257+00
1e38f142-ac9d-445b-acb4-a4bad39653ef	7b2e8562-b75d-47eb-ab92-5b6f142eb00c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:45.549791+00	\N	\N	bow	13	130	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:59:45.551132+00	2025-06-13 12:59:45.549791+00
ec087be6-2fed-4aec-bfcf-5ac386e0ffc6	4bf8ce5f-1902-4460-9424-0246f9075a38	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:45.549791+00	\N	\N	hammer	12	88	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 03:59:45.551132+00	2025-06-13 12:59:45.549791+00
d5b289fc-eec8-44c5-8f23-65d0bc6fb435	816da673-6d03-4f00-a6e3-158d0c06c45b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 12:59:45.549791+00	\N	\N	bow	28	420	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 11:59:45.551132+00	2025-06-13 12:59:45.549791+00
062ae81e-75a1-4ef3-8b9a-ff5cc4014e4e	a3f01174-f273-4724-bd43-0d09120519d0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:14.887175+00	\N	\N	dagger	14	140	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:00:14.889339+00	2025-06-13 13:00:14.887175+00
61382ede-4973-45d6-8ac7-359dc60006de	f84be4ae-d201-48bd-b1c0-e795ac710e00	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:15.41926+00	\N	\N	sword	27	297	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 18:00:15.420857+00	2025-06-13 13:00:15.41926+00
cf4ad754-3ea5-4fee-a87c-0e18a23de041	f3e9f530-50ac-40c5-bd1c-c8899ca3f1de	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:15.41926+00	\N	\N	hammer	14	102	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 00:00:15.420857+00	2025-06-13 13:00:15.41926+00
a99dc04d-f9e4-4020-8bcd-2e12eb77e4cf	2856d311-567a-4752-b818-224bccaaddb1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:15.41926+00	\N	\N	dagger	11	109	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:00:15.420857+00	2025-06-13 13:00:15.41926+00
989d53be-127a-4a05-8fe4-36e4becaf6cc	587de9e8-934d-4dac-aae2-7156379205d8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:48.446398+00	\N	\N	sword	13	95	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 09:00:48.447203+00	2025-06-13 13:00:48.446398+00
8ce6778e-ea9c-40c9-ba2d-779304600010	431fa3bd-017a-407b-bac7-cd7c749236f1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:48.446398+00	\N	\N	sword	11	80	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:00:48.447203+00	2025-06-13 13:00:48.446398+00
ff5dabd3-f62a-4d4a-875d-f7ba5a2f0c15	d3f91e2e-4ffc-40e8-9d30-02ddaadae37b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:00:48.446398+00	\N	\N	bow	11	109	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:00:48.447203+00	2025-06-13 13:00:48.446398+00
4b1f1036-7055-4617-93e5-75319487d528	284018d8-7879-4421-9b21-9bb077e861dd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:01:15.665742+00	\N	\N	staff	12	70	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:01:15.667287+00	2025-06-13 13:01:15.665742+00
fb2d65b3-f81a-4e96-94aa-14694a0db57b	2830d7fd-9ace-4836-b8b0-780b3d54c894	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:01:45.477209+00	\N	\N	hammer	21	231	rare	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 22:01:45.478395+00	2025-06-13 13:01:45.477209+00
f0dff14c-e3b2-446d-b3a2-36c5ef9ab4aa	757d9eab-ffbf-42ad-8adc-76e67c3d2992	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:01:45.477209+00	\N	\N	staff	15	87	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:01:45.478395+00	2025-06-13 13:01:45.477209+00
20642454-cf2f-4d8f-a384-bcd90e73c5c7	c9b17e51-5e40-47eb-a236-ed49be927d33	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:01:45.477209+00	\N	\N	sword	15	110	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:01:45.478395+00	2025-06-13 13:01:45.477209+00
bcffc28e-fc80-4902-96a2-effa7cc7557f	632934e2-fa3c-41e1-8292-255556a85a2a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:02:06.172281+00	\N	\N	dagger	13	130	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:02:06.174506+00	2025-06-13 13:02:06.172281+00
a83a0b62-f61b-40e8-8bf2-ee98afef0988	220dd0c9-9462-47f9-87a5-db99b8c21d40	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:02:15.725282+00	\N	\N	bow	13	130	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:02:15.72622+00	2025-06-13 13:02:15.725282+00
403eef8a-0c6f-4ecf-8928-78b0767ef32a	4b68770b-c073-4fc0-9443-be6ad2961f2e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:02:15.725282+00	\N	\N	bow	12	120	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:02:15.72622+00	2025-06-13 13:02:15.725282+00
82078a57-88ac-4bf0-a91d-1e795b03cf72	9bf31c44-8849-41f8-90c7-d3235a562bef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:02:45.440849+00	\N	\N	sword	12	88	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 09:02:45.442628+00	2025-06-13 13:02:45.440849+00
11aee2a9-a398-4516-b202-96b872982024	2bd04e33-ecd9-4c84-af60-79993492fcc2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:02:45.440849+00	\N	\N	sword	13	95	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:02:45.442628+00	2025-06-13 13:02:45.440849+00
4ffc5dd7-6941-4762-98a7-c59e6d15dc1e	62610295-b1a8-4a95-a213-e8639183c7ff	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:15.42959+00	\N	\N	staff	26	227	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 18:03:15.430509+00	2025-06-13 13:03:15.42959+00
2a8aa5f0-0ed6-4a00-86ef-00519f7e22ff	c4f4735f-fb04-4348-af43-611d1f4bb0ba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:34.225244+00	\N	\N	staff	14	81	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:03:34.226615+00	2025-06-13 13:03:34.225244+00
d92942f4-4c4a-47a8-957a-f8e3d85180f1	cd328608-73fd-410f-bbc4-32567b2e5cae	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:34.225244+00	\N	\N	hammer	24	264	common	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 08:03:34.226615+00	2025-06-13 13:03:34.225244+00
cdcea9b3-02a9-42ff-9a14-68c2f6ecf00d	6305ed81-2920-4824-b25a-23aac1005ae9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:34.225244+00	\N	\N	hammer	23	253	epic	3	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 04:03:34.226615+00	2025-06-13 13:03:34.225244+00
177811fc-3a6a-4f57-935a-3693c82e8d03	05d8780d-464e-4413-9674-4fc58407480e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:45.491135+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:03:45.493744+00	2025-06-13 13:03:45.491135+00
7ed17a51-3bb8-4889-8c64-7ae91f6db5b7	6d599025-b548-475f-bb6c-3daf1eb6b9ef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:45.491135+00	\N	\N	hammer	22	242	rare	1	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 01:03:45.493744+00	2025-06-13 13:03:45.491135+00
22b0a02c-7840-41d6-a0ff-4053f3cc6201	2d54e7e3-639a-45f3-8fb5-88c7a84c6f0a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:03:45.491135+00	\N	\N	bow	24	360	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 04:03:45.493744+00	2025-06-13 13:03:45.491135+00
89d32b0f-212a-4827-af6d-5364b927735e	936024af-728a-4f8d-bbf8-d7a21e32cbb1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:04:15.714434+00	\N	\N	hammer	13	95	common	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 13:04:15.715582+00	2025-06-13 13:04:15.714434+00
d0ec4b97-b99e-4660-a13e-10fe36b5ded7	84eb0718-9fc3-496e-9a19-c120c70633c3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:04:17.264805+00	\N	\N	sword	12	88	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:04:17.265832+00	2025-06-13 13:04:17.264805+00
060b5b1c-569a-46d6-82cc-733aadcbd987	6aefd13b-ade6-4478-8f0f-d56d3b5892a2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:04:17.264805+00	\N	\N	sword	14	102	rare	4	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:04:17.265832+00	2025-06-13 13:04:17.264805+00
389e0538-894e-453f-b505-866c935fa217	5ba2a130-f582-4213-a2db-22d681603c9d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:04:45.424176+00	\N	\N	sword	15	110	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 11:04:45.425313+00	2025-06-13 13:04:45.424176+00
12a540fb-cd8c-4010-9b99-9833849184fa	e8ce8661-98ee-4d69-bc65-c80ef4a1c79c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:04:45.424176+00	\N	\N	hammer	11	80	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 22:04:45.425313+00	2025-06-13 13:04:45.424176+00
94f6d83e-9450-4bbf-a1df-2b7630192059	6b7e64f0-2e79-4077-af76-b28f00610bcd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:05:45.408138+00	\N	\N	staff	11	64	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:05:45.409025+00	2025-06-13 13:05:45.408138+00
266e9d0a-3c5c-4928-bb06-6879522835ec	059fab66-d854-47c1-90c6-9a04c07ea280	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:45.420717+00	\N	\N	sword	12	88	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 13:06:45.421563+00	2025-06-13 13:06:45.420717+00
73cffee3-fdc5-4455-a1c4-badc8d5f7dc3	62382620-690d-4cb5-a34a-dcd534da383b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:45.420717+00	\N	\N	bow	11	109	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:06:45.421563+00	2025-06-13 13:06:45.420717+00
e40cfc46-dddb-4629-84c8-d09625abd7f2	200788ca-90a0-4441-a319-ab34827e679d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:08:15.385175+00	\N	\N	sword	12	88	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:08:15.386018+00	2025-06-13 13:08:15.385175+00
b03e4515-c93c-4a56-a3a5-d38f2b839fb5	ec76028b-c388-427a-a470-634d1589d73b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:15.409633+00	\N	\N	hammer	24	264	epic	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-14 10:09:15.411031+00	2025-06-13 13:09:15.409633+00
20515662-e2f0-4a87-804a-277bc0eacfe6	9154b6e6-2f02-40c2-88d7-12602d5908f4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:15.409633+00	\N	\N	staff	13	75	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:09:15.411031+00	2025-06-13 13:09:15.409633+00
f83f6f6c-ceb7-4c3b-8627-133c2f9844e7	efa1dd0e-2df5-4aeb-a9ed-387dd573aa81	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:45.465851+00	\N	\N	staff	12	70	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:09:45.466916+00	2025-06-13 13:09:45.465851+00
1a6a29a5-9524-47cd-b3f3-4acfd443ce66	3eaefccc-f0fc-46a4-92fd-95d3e481d2e2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:45.465851+00	\N	\N	staff	13	75	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:09:45.466916+00	2025-06-13 13:09:45.465851+00
18506f0e-6710-491b-b241-42893fa1a846	a647b589-4f8e-4cf2-8132-faa6a699b8ec	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:11:32.547294+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:11:32.549029+00	2025-06-13 13:11:32.547294+00
7a70bfea-8772-4a67-965c-ab4f44777aeb	2c237c63-b6ba-45be-aa54-57b103a90fba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:47.271588+00	\N	\N	staff	17	99	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:13:47.27387+00	2025-06-13 13:13:47.271588+00
4a168f40-ae59-405a-a9fe-cb7e06c35e9f	d62cdd9b-5533-4530-9e19-1461f4209e65	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:47.271588+00	\N	\N	bow	16	160	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:13:47.27387+00	2025-06-13 13:13:47.271588+00
94e987f0-ad01-4624-bbf6-cf42112897a6	1f350145-a38d-4560-9602-79de4ef8fdaa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:47.271588+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:13:47.27387+00	2025-06-13 13:13:47.271588+00
1b7b718c-e669-441c-a802-b843b0ad3078	114e055f-3751-4ae8-803c-5a12d7730214	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:19.828944+00	\N	\N	bow	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:14:19.830466+00	2025-06-13 13:14:19.828944+00
fc2c0a32-b1b2-469b-9adf-a4fa0e7a2d29	e6009b98-f5ac-458d-81e3-05b06c8af731	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:05:15.395612+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:05:15.396534+00	2025-06-13 13:05:15.395612+00
337ffe3a-8b4b-46cb-a3ad-c4c2a6d40c23	75951204-488d-48c9-bb54-60214366a099	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:04.330882+00	\N	\N	hammer	12	88	common	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 05:06:04.332291+00	2025-06-13 13:06:04.330882+00
f9454d09-3b9f-4937-8a0c-043c507ab599	669b4c56-7ca0-46d0-846e-7977093c1caa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:04.330882+00	\N	\N	staff	13	75	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:06:04.332291+00	2025-06-13 13:06:04.330882+00
d7824871-42ff-42a4-a7a9-ae83ade448d1	90e5785f-d0c1-468e-9ca5-b8eaf16662d7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:04.330882+00	\N	\N	sword	12	88	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:06:04.332291+00	2025-06-13 13:06:04.330882+00
551ebe3e-6cc3-45cf-8f02-abd0a00a2e89	9afa6aec-e0c6-4968-b302-bb63e0fc2841	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:15.408403+00	\N	\N	sword	12	88	rare	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 10:06:15.409136+00	2025-06-13 13:06:15.408403+00
52b562d8-19ef-45ec-a59b-194e345d6529	627eeb4e-8235-4c19-b17d-aa7a038db3dc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:15.408403+00	\N	\N	bow	13	130	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:06:15.409136+00	2025-06-13 13:06:15.408403+00
055415a5-f165-436e-aa27-23ed71f857bc	11b42bf7-f06e-4c54-86b6-e5cc879c790e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:55.382345+00	\N	\N	sword	11	80	rare	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 23:06:55.383541+00	2025-06-13 13:06:55.382345+00
f0d259f6-065b-4d4b-855a-7e421c6cd330	528e4360-a3f5-4057-8d2b-d92f0056502f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:55.382345+00	\N	\N	sword	11	80	rare	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 02:06:55.383541+00	2025-06-13 13:06:55.382345+00
c3edcd07-cb8d-4634-8359-ef543d33065e	9ca70ead-e63d-4cfb-a920-5a6ea7390232	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:06:55.382345+00	\N	\N	staff	13	75	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:06:55.383541+00	2025-06-13 13:06:55.382345+00
3b9695bd-fbc0-4685-ba8f-6308d09c3a66	d354cbba-c5b7-42a8-910f-6d79fedd64e9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:07:15.438851+00	\N	\N	hammer	15	110	common	3	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 01:07:15.439982+00	2025-06-13 13:07:15.438851+00
dd96d9c7-b7c0-49b4-b371-e5f1072f9ee4	902229c9-dfa4-4951-ae54-90af16192372	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:07:45.43785+00	\N	\N	hammer	21	231	common	4	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 18:07:45.439323+00	2025-06-13 13:07:45.43785+00
87f474ca-488a-4d96-a2fb-a167ba33624e	ccc81575-0803-4f76-92c6-787541d48c2e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:07:45.43785+00	\N	\N	hammer	13	95	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 08:07:45.439323+00	2025-06-13 13:07:45.43785+00
b3894128-61df-4e1b-b75e-2f269f240b9a	d8502c25-ba27-427f-875d-899eeb2d05cf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:07:45.43785+00	\N	\N	staff	15	87	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:07:45.439323+00	2025-06-13 13:07:45.43785+00
98f6ce3f-2d44-42ae-ac17-d7c216f632b6	abf9a19a-bab2-4b60-a9af-126426daca1d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:08:15.423048+00	\N	\N	bow	12	120	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:08:15.42406+00	2025-06-13 13:08:15.423048+00
aac343e7-45d3-497f-8eca-67651cc1b293	61935c32-0782-47a8-a0be-fd5330032703	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:08:15.423048+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:08:15.42406+00	2025-06-13 13:08:15.423048+00
f112d14f-56cc-4ac4-8202-7b419b2ea2d8	6b80ae3c-a475-47c1-950d-9f123a0d333e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:08:45.42208+00	\N	\N	sword	14	102	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 09:08:45.423326+00	2025-06-13 13:08:45.42208+00
7a77c33c-2c82-4dbd-aec5-e2c3825bbead	3edfb7d4-9502-4c24-9361-3ba9f8ef5c41	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:08:45.42208+00	\N	\N	sword	14	102	common	5	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 16:08:45.423326+00	2025-06-13 13:08:45.42208+00
2118b79b-89c2-4cf5-b466-0e04b02c5c09	dd3a914b-2f2e-4817-820a-a2f7511f6f94	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:06.467288+00	\N	\N	dagger	13	130	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:09:06.468147+00	2025-06-13 13:09:06.467288+00
0fe0d35b-1fd9-43be-ac44-f16204134098	876488bb-b4f8-4374-9638-071ae399ee1a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:09:06.467288+00	\N	\N	hammer	12	88	rare	1	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-13 20:09:06.468147+00	2025-06-13 13:09:06.467288+00
5c4e9d08-3638-479e-b52a-0ce6ef03ff54	1e3ba41d-a31f-4e52-bff0-992e3f39da44	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:15.43042+00	\N	\N	bow	13	130	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:10:15.43136+00	2025-06-13 13:10:15.43042+00
85c33509-d22c-4233-a73e-002c0f07fa98	ee2fb295-af45-40ab-940a-b22df890021b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:37.502269+00	\N	\N	hammer	28	308	epic	5	【CHALLENGE】friendlyなwarriorからのリクエスト	2025-06-13 16:10:37.503353+00	2025-06-13 13:10:37.502269+00
2907dd91-161f-4e7a-b794-61df917de14e	c3bb400a-1531-4204-82be-10f01b5452ba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:37.502269+00	\N	\N	bow	13	130	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:10:37.503353+00	2025-06-13 13:10:37.502269+00
d75fc11a-484d-4cb8-98b4-09222b1b8042	a8ebb7ce-ec89-46ba-806d-203fc958e977	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:37.502269+00	\N	\N	dagger	12	120	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:10:37.503353+00	2025-06-13 13:10:37.502269+00
f7237ba7-478a-4f22-87c0-6c4bd782cbfd	9e7023ad-78dd-4e05-9c3c-35468d322282	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:45.409626+00	\N	\N	staff	11	64	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:10:45.410438+00	2025-06-13 13:10:45.409626+00
c21d3671-a068-4bc7-9706-a752e123ecee	be847ac7-127b-4540-842f-ee859e4a81ce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:45.409626+00	\N	\N	staff	13	75	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:10:45.410438+00	2025-06-13 13:10:45.409626+00
ee6a16f3-008e-44c3-bfe0-3ee276b06e7d	9fb56290-bd0e-46c5-94f4-f3c374c32bd8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:10:45.409626+00	\N	\N	sword	12	88	common	2	【NORMAL】friendlyなwarriorからのリクエスト	2025-06-14 06:10:45.410438+00	2025-06-13 13:10:45.409626+00
99dd56e4-c72a-4680-b161-f11d33cb1ff7	382123e0-eae9-4aa5-8286-711fb49c1b89	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:11:15.427114+00	\N	\N	bow	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:11:15.428112+00	2025-06-13 13:11:15.427114+00
90cc429f-c696-4b53-8d9d-03b98fd6a2a3	d429e28f-00dd-401e-833e-5ed70e234436	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:11:45.410138+00	\N	\N	bow	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:11:45.411098+00	2025-06-13 13:11:45.410138+00
4b0b28f2-82a8-415c-ab5c-bbc2b6ff6ba5	23bbbea1-34c3-4198-8174-ac1430f0e020	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:15.393377+00	\N	\N	bow	18	180	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:12:15.394286+00	2025-06-13 13:12:15.393377+00
edc1c3fa-0822-421f-8bfd-ff68367b3a83	8a64a893-0de9-4631-ad91-7e3ba39a5abf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:15.393377+00	\N	\N	bow	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:12:15.394286+00	2025-06-13 13:12:15.393377+00
ff95e990-f717-4235-b335-cb5fd69afc91	d5448ee5-274c-42ad-b39c-2c5fdfb46223	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:15.393377+00	\N	\N	staff	16	93	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:12:15.394286+00	2025-06-13 13:12:15.393377+00
e815f183-0417-4cae-abd3-b306911a9534	b8359bf3-87b4-4c5e-917b-eafb733a4a05	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:19.578878+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:12:19.580667+00	2025-06-13 13:12:19.578878+00
7f79b46a-3869-4460-9fc2-209ad3ede9f0	3a225f80-7a43-4f84-b950-16a4e0c6325c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:45.417177+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:12:45.418302+00	2025-06-13 13:12:45.417177+00
002db4b0-c179-4f4f-afb0-55da04043113	cc111a59-e37d-4821-a541-0684daffda1e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:45.417177+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:12:45.418302+00	2025-06-13 13:12:45.417177+00
b842828a-304e-4037-b414-47abb860ae0b	91d7edd0-e1c7-4c4b-820e-bc06e7365dc8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:12:45.417177+00	\N	\N	staff	28	244	common	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 18:12:45.418302+00	2025-06-13 13:12:45.417177+00
417c0f40-a93a-4e08-93aa-ed01eac6ef6c	6a0d00e1-fb01-47d5-ade2-56a340162394	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:15.460044+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:13:15.461203+00	2025-06-13 13:13:15.460044+00
0426f8ce-c217-411a-9277-89a7fe462127	28d4c558-dfed-49a4-9177-923a250990ee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:15.460044+00	\N	\N	bow	18	180	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:13:15.461203+00	2025-06-13 13:13:15.460044+00
81a4acea-81c1-44d4-8516-2870230c9fd9	801fcbb9-10f4-4e8f-a8f2-e0bbf7f7e66f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:13:15.460044+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:13:15.461203+00	2025-06-13 13:13:15.460044+00
5e788fa2-a50f-4989-9a7c-9f96b0e8deef	74231a45-2ba0-402b-a51c-7ad4bf227a4b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:17.160295+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:14:17.161281+00	2025-06-13 13:14:17.160295+00
d5bac550-7f36-468a-9811-3392c2743c3f	8c336b7e-1ec2-4658-81f3-26da996f0d6d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:17.160295+00	\N	\N	dagger	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:14:17.161281+00	2025-06-13 13:14:17.160295+00
c480039c-0be4-4706-bf86-ee5cfc11f46b	b94e9825-ce21-403d-a350-f959d5aec586	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:17.160295+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:14:17.161281+00	2025-06-13 13:14:17.160295+00
d3310360-6fd8-4ac0-9704-03252de09743	1ec09aa4-e804-4132-b312-56b3e020dc32	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:47.152746+00	\N	\N	dagger	17	170	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:14:47.15369+00	2025-06-13 13:14:47.152746+00
405fdf31-6bda-4a9e-bd78-74e296f45aa5	e40de087-03aa-48fd-8920-00509652d2e3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:47.152746+00	\N	\N	dagger	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:14:47.15369+00	2025-06-13 13:14:47.152746+00
0f6a2f7b-7d6d-46e4-9ae0-0e40aa360b08	ba4869ec-83bd-40cf-ac61-7a39b11f0d1b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:14:47.152746+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:14:47.15369+00	2025-06-13 13:14:47.152746+00
1e56167e-9349-4cba-b1e0-da7018179a49	825f189d-642b-4620-99b2-6fb5d2c90a86	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:17.225668+00	\N	\N	dagger	29	435	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:15:17.226607+00	2025-06-13 13:15:17.225668+00
6f040b5d-e452-4162-9374-bc91e4e09800	e834a8bd-9d74-4dad-ab08-84dbc8f3a5bd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:47.112554+00	\N	\N	dagger	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:15:47.113377+00	2025-06-13 13:15:47.112554+00
e46aa6e6-5810-4799-a3c0-614590e444a4	84285c34-b40a-4065-bd79-a30ae6d748bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:47.112554+00	\N	\N	staff	18	105	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:15:47.113377+00	2025-06-13 13:15:47.112554+00
bf82ce88-b5b6-43cc-be28-34195b2ff72e	365522da-8783-4299-95fe-c9b1ec5b1da1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:57.880026+00	\N	\N	bow	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:15:57.881709+00	2025-06-13 13:15:57.880026+00
23300755-e117-4fe8-b17b-5af1711eeb92	14749dc3-dd71-483e-9216-4adf8b747cff	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:57.880026+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:15:57.881709+00	2025-06-13 13:15:57.880026+00
d05b04bd-ddf6-4905-86b9-beae0c63c73b	eb058689-05e7-42ae-8229-3b742090661e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:15:57.880026+00	\N	\N	staff	17	99	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:15:57.881709+00	2025-06-13 13:15:57.880026+00
e76df03e-e4e0-464d-863c-1e7d1ccc5c71	e146543d-d13f-4a6a-88df-a99fc301ade7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:16:17.117066+00	\N	\N	dagger	32	480	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:16:17.118118+00	2025-06-13 13:16:17.117066+00
ebdef4f8-eb8c-4470-84bc-f4f75d4698db	cd2f09b6-619d-4c40-9e6e-fc487885b69c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:16:47.157464+00	\N	\N	staff	16	93	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:16:47.158552+00	2025-06-13 13:16:47.157464+00
38084eeb-32a0-40ce-b59c-53b0adce7a85	d6af4616-2aad-4810-8d27-1e83685b86d0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:16:47.157464+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:16:47.158552+00	2025-06-13 13:16:47.157464+00
6d05d66c-fa4b-4c7b-801c-438e980f389f	fe9b5df3-15d4-40f2-945d-24509ad9ee32	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:16:47.157464+00	\N	\N	dagger	27	405	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 20:16:47.158552+00	2025-06-13 13:16:47.157464+00
219b2569-3205-454d-baba-f57048c0488f	380fc4dc-a009-4bc5-abb3-8b3e5a723589	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:17:17.111303+00	\N	\N	bow	19	190	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:17:17.112434+00	2025-06-13 13:17:17.111303+00
066b276d-5a96-42d8-948e-8b5c8f2b8fca	19a2c954-4441-42e7-a6ca-8a1baecfd0eb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:17:17.111303+00	\N	\N	dagger	25	375	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 16:17:17.112434+00	2025-06-13 13:17:17.111303+00
399c3f84-202d-46e2-bc2f-ef6d3573aa5a	e7b09c99-253c-4e43-9537-e9044c1a3a62	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:17:17.111303+00	\N	\N	dagger	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:17:17.112434+00	2025-06-13 13:17:17.111303+00
4fe57674-fa98-45ea-8ec9-c064c9dfef4f	18985d68-13e5-4081-9299-76490e9500df	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:17:44.923972+00	\N	\N	staff	16	93	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:17:44.925347+00	2025-06-13 13:17:44.923972+00
eb3367e6-232a-47bd-b49e-7751ad00fbcd	7eb0571f-a928-432b-ab08-f3fc6d482a9d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:17:47.120869+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:17:47.122282+00	2025-06-13 13:17:47.120869+00
11651b58-1f0e-42ca-9f9a-c808569c4a06	b383332f-b561-42a5-9d93-9d4ebe5d3b49	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:18:17.005603+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:18:17.006645+00	2025-06-13 13:18:17.005603+00
f8e76fc7-fc7e-4c44-a274-99e440b8a507	110e5391-7043-4143-8812-ac72bb74af25	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:18:17.005603+00	\N	\N	bow	15	150	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:18:17.006645+00	2025-06-13 13:18:17.005603+00
af65b496-6784-4b22-a0e1-ef7add3955ab	3b7ffafa-11b5-4064-bfa3-f66c1a87fc46	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:18:17.005603+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:18:17.006645+00	2025-06-13 13:18:17.005603+00
c5b255e9-18a6-4386-94ed-8653b0cdd00c	33d29014-fb7c-4bcd-a991-89dde316f761	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:18:31.977391+00	\N	\N	staff	17	99	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:18:31.978462+00	2025-06-13 13:18:31.977391+00
e4c56510-1ea2-4de4-9f35-62909cb119b6	af70a838-c859-4c4b-8dd4-f7308fa14ffd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:18:47.064375+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:18:47.065676+00	2025-06-13 13:18:47.064375+00
c7f7af8e-14df-49c9-b56f-be59cef94a61	7b2ddeb4-f5b1-4e22-9a9a-c8574063e500	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:19:17.021077+00	\N	\N	staff	29	253	epic	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 12:19:17.021968+00	2025-06-13 13:19:17.021077+00
27c1c368-3a6c-4b57-8a77-d39d7b760301	0f498357-43b4-4dfd-9577-a09571ed4c72	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:19:47.064587+00	\N	\N	dagger	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:19:47.065779+00	2025-06-13 13:19:47.064587+00
899b761b-aba8-4ced-9d5d-c62889ee8af8	6f5b2d14-6707-46f7-a5d4-08eacc7d5f7f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:19:47.064587+00	\N	\N	dagger	26	390	epic	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 05:19:47.065779+00	2025-06-13 13:19:47.064587+00
8fd83c69-3704-449b-a81f-8c864e3d1b8c	b954792a-3298-4d7f-9f43-d13865944c03	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:19:47.064587+00	\N	\N	bow	32	480	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:19:47.065779+00	2025-06-13 13:19:47.064587+00
c84fa461-19e4-40ed-8fed-d33bdac80b1d	efd0d42f-1f5c-4f41-898a-526cf1c88cac	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.005158+00	\N	\N	staff	19	110	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:20:17.011118+00	2025-06-13 13:20:17.005158+00
907078d3-daf1-40fa-a2d4-c9fc33b389d5	efb0c2ab-3b52-419f-81dc-bc06c7cf9431	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.005158+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:20:17.011118+00	2025-06-13 13:20:17.005158+00
c96c8e69-50b4-4863-8632-61ad0ee3ecbf	5b064b1b-bc7f-400e-895a-dfda1be8768f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.005158+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:20:17.011118+00	2025-06-13 13:20:17.005158+00
19bdb088-15ae-40f3-8786-a2a76ea8165d	89b734bb-0495-4c8d-b065-e2e10523b288	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.166584+00	\N	\N	staff	19	110	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:20:17.169549+00	2025-06-13 13:20:17.166584+00
7208111d-c54b-4ecd-9c96-abe2cf13b57b	d09f9203-4fe1-4d6f-b94f-8fb8de50304f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.166584+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:20:17.169549+00	2025-06-13 13:20:17.166584+00
34cbd518-b3c4-4618-bd46-f5375a691226	914d5eda-32e1-4fd9-acc7-17b45257390c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:17.166584+00	\N	\N	bow	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:20:17.169549+00	2025-06-13 13:20:17.166584+00
95dc0ca7-fb52-4e4e-a07c-dfab8d30f87a	bca0292f-9723-46e8-be63-b8b064c71d3f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:47.100562+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:20:47.101877+00	2025-06-13 13:20:47.100562+00
6fc36552-4b55-4491-914d-41ecfbafce1b	b9dc2647-b948-4135-b970-1e593123dc00	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:47.100562+00	\N	\N	dagger	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:20:47.101877+00	2025-06-13 13:20:47.100562+00
24289d82-d7ef-4d34-8a30-f693726cd5a6	d7909d08-29c8-4264-b47f-2301b2906660	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:20:47.100562+00	\N	\N	staff	29	253	rare	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 07:20:47.101877+00	2025-06-13 13:20:47.100562+00
1e0b50f9-4a67-4893-a33d-c2cb9f94879a	a2c4711a-9324-42e9-932a-6bfc3734ca3f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:17.156043+00	\N	\N	staff	31	271	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 12:21:17.15771+00	2025-06-13 13:21:17.156043+00
ac92d48b-5599-49b7-8edf-813c7af5d025	b0636653-af84-4544-aee5-dde8e628cb89	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:17.156043+00	\N	\N	bow	17	170	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:21:17.15771+00	2025-06-13 13:21:17.156043+00
929f7df6-4190-4d25-b79a-c0557027970e	c1c2ac73-ab39-4dc1-ba0e-d987694eb1a5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:17.156043+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:21:17.15771+00	2025-06-13 13:21:17.156043+00
138014ad-f50d-498c-b2fa-0b7a7c12cf8e	e2175269-441f-4057-bfc9-79bbe0e47711	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:23:17.153161+00	\N	\N	bow	16	160	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:23:17.154026+00	2025-06-13 13:23:17.153161+00
5e74ce48-d143-44b9-b959-ec400eb972d4	85cfd013-ea77-488b-8481-d3eb4bd75cfb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:23:17.153161+00	\N	\N	staff	29	253	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 23:23:17.154026+00	2025-06-13 13:23:17.153161+00
be50af02-5a33-4319-950c-0487c1cc948c	f9d32f3d-686a-4af8-aa28-60cdee717618	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:23:17.153161+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:23:17.154026+00	2025-06-13 13:23:17.153161+00
e83e93f8-bf46-4cac-b42e-33956b7d82fa	7fedb2ed-af55-41e3-9a85-e593debeebaa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:47.114875+00	\N	\N	staff	29	253	epic	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 09:21:47.116187+00	2025-06-13 13:21:47.114875+00
69c2a804-acd7-44b7-b964-8d00acf89937	954bf019-48c7-4ad9-906c-05b13adabc5e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:47.114875+00	\N	\N	bow	31	465	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:21:47.116187+00	2025-06-13 13:21:47.114875+00
7b369d74-808e-47b8-b366-626bc940e050	51a71a56-c7d0-48c8-b285-7ea35bf73f78	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:21:47.114875+00	\N	\N	bow	15	150	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:21:47.116187+00	2025-06-13 13:21:47.114875+00
a7eb84be-17e7-4736-9b55-4553bcff2563	1d6eb81d-d256-4891-b8cc-93d4208e9256	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:17.123847+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:22:17.12477+00	2025-06-13 13:22:17.123847+00
1518ca82-178f-47cd-8d5c-ee6dd395c914	0d7e7a34-950a-4e5c-8985-078aa2343dde	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:47.085046+00	\N	\N	dagger	19	190	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:22:47.086162+00	2025-06-13 13:22:47.085046+00
7655c61e-86e8-4c9c-bd2e-241cd41962e3	2c7b7fcb-45fe-44b9-8270-7b5097cca983	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:16.160804+00	\N	\N	staff	17	99	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:22:16.162088+00	2025-06-13 13:22:16.160804+00
c94218de-aaed-49ae-8dc8-29bfb2644961	a42a9990-0073-4155-b051-6f0fab59df4f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:16.160804+00	\N	\N	dagger	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:22:16.162088+00	2025-06-13 13:22:16.160804+00
489d85f1-a343-4643-9608-e22fe934a214	b951f778-deae-45c2-b75e-921849cc94e6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:51.213332+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:22:51.215063+00	2025-06-13 13:22:51.213332+00
6a73ef66-b961-485c-b087-f97e6769dd95	295611ed-5297-4906-bf2b-969ad66b0033	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:22:51.213332+00	\N	\N	bow	17	170	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:22:51.215063+00	2025-06-13 13:22:51.213332+00
4759bf3d-d979-4272-9949-fc49574b30d5	4e497462-4319-4907-96fd-3959cf54e670	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:23:49.715906+00	\N	\N	bow	25	375	epic	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 11:23:49.7175+00	2025-06-13 13:23:49.715906+00
39d7fce1-8cce-45e4-91ba-8a34210caedb	2dec2ec5-0a41-4a2d-8ed0-bd0f9182fa01	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:17.437727+00	\N	\N	dagger	18	180	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:24:17.439247+00	2025-06-13 13:24:17.437727+00
f2873d6e-1423-48e9-a68f-31199156e2fc	0bbe4279-3f94-46a3-bf05-028c92c66dcf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:17.437727+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:24:17.439247+00	2025-06-13 13:24:17.437727+00
6d0b5548-17c4-4312-b4ce-955526eea082	f994ec8c-90b0-4274-8789-938eb5aec0d6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:17.437727+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:24:17.439247+00	2025-06-13 13:24:17.437727+00
071664b1-ae53-4544-b053-29c4f97cd153	fd6cbb45-f121-4864-ab60-b63a6e0c14c9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:24.844436+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:24:24.846722+00	2025-06-13 13:24:24.844436+00
2400f900-4e44-42e0-a978-23b49dbc2f78	f456f2df-8abf-465f-866d-45b4e1d8146b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:24.844436+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:24:24.846722+00	2025-06-13 13:24:24.844436+00
d31f75f8-ef9f-4605-811b-69f926745b78	08f7c41b-506c-4317-a090-93bdfb7b8e46	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:24.844436+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:24:24.846722+00	2025-06-13 13:24:24.844436+00
20d637f4-8158-4abe-bf14-15786166200b	e4e4ce66-8f35-43b9-a9fd-e8f94d3ddf6b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:24:47.451111+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:24:47.451867+00	2025-06-13 13:24:47.451111+00
5ce1b084-d8a2-40c9-b959-cef897e89f33	f5227e24-8c50-4124-9d9a-f91a8159b3a3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:17.323931+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:25:17.325764+00	2025-06-13 13:25:17.323931+00
31b6923e-f390-4768-ad56-d0589e3b4631	92b6f090-8eee-4acc-bdd8-b910ebf51b84	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:17.323931+00	\N	\N	bow	18	180	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:25:17.325764+00	2025-06-13 13:25:17.323931+00
8c8b9745-a9f2-461a-94d4-05c9f4ce37cc	0d05e00f-6dbf-4e27-b748-4fdbea5a2ed9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:47.153519+00	\N	\N	staff	17	99	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:25:47.154513+00	2025-06-13 13:25:47.153519+00
4914e20e-a40c-405e-b454-8764b7ae8979	02b64cf3-60bd-4838-9dd3-2f825b1ae359	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:55.918321+00	\N	\N	staff	28	244	epic	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 23:25:55.919583+00	2025-06-13 13:25:55.918321+00
77cb8238-90ce-43e0-ae7a-c29c3651887e	39dced39-ca53-4574-b3c1-9ce517420246	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:55.918321+00	\N	\N	bow	29	435	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 10:25:55.919583+00	2025-06-13 13:25:55.918321+00
76a48ba5-d25e-4c20-b62b-75aa046be04e	b14e4529-9888-4717-88a2-3671bd9a0c4d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:25:55.918321+00	\N	\N	bow	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:25:55.919583+00	2025-06-13 13:25:55.918321+00
e587daa6-33c5-4c8a-b86a-46d7eeb6a3c7	39005e4b-ac3a-4aea-96de-551f075ddaf5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:26:17.267997+00	\N	\N	staff	15	87	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:26:17.268994+00	2025-06-13 13:26:17.267997+00
9f1a8c1d-f2d5-41ca-9c9a-036fa99fa05a	164f24bc-f48a-4b64-a005-4f0deeaa4f54	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:26:47.360832+00	\N	\N	bow	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:26:47.361928+00	2025-06-13 13:26:47.360832+00
48bd2a8b-9cff-4a46-a97e-577a132b574a	6a9a4a5f-e196-4ade-b641-2402f56b1007	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:02.279043+00	\N	\N	staff	16	93	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:27:02.281431+00	2025-06-13 13:27:02.279043+00
0eda475f-caab-4ce7-bd3b-dfb737063a0b	d02c4bf6-426d-4c60-adad-45adfbae53ca	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:02.279043+00	\N	\N	bow	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:27:02.281431+00	2025-06-13 13:27:02.279043+00
9ad17a07-cb91-490f-8013-01a6b3bfbfc6	01b39766-fecd-4fe4-a662-1d4c05277873	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:02.279043+00	\N	\N	dagger	17	170	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:27:02.281431+00	2025-06-13 13:27:02.279043+00
47519c45-cf0b-4a58-a4f8-c06ced89a83e	d8f50817-557f-419f-b660-5a51ece2879d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:17.177829+00	\N	\N	bow	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:27:17.178701+00	2025-06-13 13:27:17.177829+00
91a006a6-98c4-4801-836f-853ebe0f31f8	2dbbf6cc-8b83-466e-aab1-cb01906d2fb0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:17.177829+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:27:17.178701+00	2025-06-13 13:27:17.177829+00
3ac3ca91-5467-4f6c-9ac4-9ef5e0111f52	cb99c7a0-678a-4786-846e-e085a1ee0108	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:47.180135+00	\N	\N	staff	19	110	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:27:47.182725+00	2025-06-13 13:27:47.180135+00
b1a1a602-37e7-4867-b624-74b5925b5f79	45181512-fb4c-49f2-a678-1f2d0637ab27	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:47.180135+00	\N	\N	dagger	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:27:47.182725+00	2025-06-13 13:27:47.180135+00
d98f009e-b45a-471d-a415-bb3004efa994	fe379f0e-9af0-48e0-ba49-fc5a4845109d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:27:47.180135+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:27:47.182725+00	2025-06-13 13:27:47.180135+00
c450acfb-f127-45c4-9f2f-7db2bd43cad6	8e3e67be-8b3f-4a99-8a6c-4c020f7d9ff5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:29:46.184701+00	\N	\N	dagger	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:29:46.186117+00	2025-06-13 13:29:46.184701+00
f8b5b295-1258-4a35-9ed4-e468c832528c	0cf91860-2db3-4523-b2db-e30508c9b2d7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:29:46.184701+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:29:46.186117+00	2025-06-13 13:29:46.184701+00
5401d66b-9d14-4489-b5fa-ef169e71be20	3199ddcb-6803-4dd6-a7db-241c5e24eb91	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:29:46.184701+00	\N	\N	staff	15	87	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:29:46.186117+00	2025-06-13 13:29:46.184701+00
c236493c-7e82-49a3-84ae-3ac036f53bb9	7e376b72-4a8e-4ac5-8881-01c00401068a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:16.00358+00	\N	\N	dagger	15	150	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:30:16.004371+00	2025-06-13 13:30:16.00358+00
6d9be142-02ec-406d-a937-60aefe8473ba	f9505cd6-70b3-4315-a526-dea0c8cc5c57	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:16.00358+00	\N	\N	dagger	19	190	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:30:16.004371+00	2025-06-13 13:30:16.00358+00
0f7ccacc-4cf3-424d-8c2e-a5406a26b278	2c1b541a-d46c-4fb8-8396-2209a754e36a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:16.00358+00	\N	\N	staff	16	93	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:30:16.004371+00	2025-06-13 13:30:16.00358+00
129cb0af-ef7f-4d81-9ce1-36467bbc1ced	1d522546-baaf-4e49-8feb-f3fc17b58ca7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:53.300513+00	\N	\N	dagger	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:30:53.302654+00	2025-06-13 13:30:53.300513+00
3e26606c-6cf1-4754-8172-56a7335c9cf6	98cf9608-46ae-4117-8a71-a3658c237dd8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:53.300513+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:30:53.302654+00	2025-06-13 13:30:53.300513+00
ac42c8d5-60a1-49ae-9a25-019802e84496	b8bdc96f-cc51-4c41-b3f6-41a7e0c882c3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:30:53.300513+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:30:53.302654+00	2025-06-13 13:30:53.300513+00
37d98dc5-bf1d-408e-a099-d4e718bdc893	e53ad94d-eef4-4585-b0d8-8927a371b2f0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:31:23.003352+00	\N	\N	staff	16	93	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:31:23.004608+00	2025-06-13 13:31:23.003352+00
a8fc173b-9d33-44eb-b6b8-c9326bffa769	04a4a2d0-b68f-45dd-9c3a-8a9162299df0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:31:52.992413+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:31:52.993621+00	2025-06-13 13:31:52.992413+00
66b75ee6-c5e0-4cf2-af06-81290867f794	e440c2f7-4ce0-40b9-97ad-ab69cc487634	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:31:52.992413+00	\N	\N	dagger	18	180	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:31:52.993621+00	2025-06-13 13:31:52.992413+00
3c1600dd-8207-45f4-90b1-2821b774fa94	c9447b25-c5d2-4880-9674-9f4ccda139bf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:32:23.017676+00	\N	\N	dagger	25	375	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:32:23.018702+00	2025-06-13 13:32:23.017676+00
47e6d03e-7788-4fac-8c84-e87f430a01e9	5a8dca0a-14d1-483f-a646-7903e454c27d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:32:23.017676+00	\N	\N	dagger	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:32:23.018702+00	2025-06-13 13:32:23.017676+00
deb5c5d3-ad09-4b6c-868a-c77232f7d395	b3137232-a1b4-4ef6-aa58-e4babd85ab53	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:32:23.017676+00	\N	\N	bow	18	180	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:32:23.018702+00	2025-06-13 13:32:23.017676+00
03806866-815a-4e1a-b625-694e31020b5d	ee751a29-1bdf-47fd-a94a-a4c8192527da	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:34:07.799438+00	\N	\N	dagger	25	375	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 07:34:07.800366+00	2025-06-13 13:34:07.799438+00
687fc934-482e-486c-a7b1-45613ea523da	c5569ad3-d403-487e-b2e2-21bc68746ba9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:32:44.807622+00	\N	\N	staff	32	280	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 23:32:44.811497+00	2025-06-13 13:32:44.807622+00
d24e237d-e2ff-42e2-adf9-7f10e4e90d9c	9378d2c9-4c40-4601-b191-367ab7ce96ae	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:50.61814+00	\N	\N	bow	28	420	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:33:50.620123+00	2025-06-13 13:33:50.61814+00
166a93af-3da6-4a8d-b5fb-dc185c206e83	e0ccadd6-7552-49fc-9171-786c45383bce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:50.61814+00	\N	\N	bow	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:33:50.620123+00	2025-06-13 13:33:50.61814+00
0010b0af-656d-4145-a958-06931bc85650	9a25652b-4f68-4f50-a6af-58b3cb1c267a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:50.61814+00	\N	\N	staff	19	110	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:33:50.620123+00	2025-06-13 13:33:50.61814+00
22f15c5d-e768-4568-9fd5-cc43b06bf2be	e89231ab-2441-4be6-a0c8-09b6acfbf272	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:08.052433+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:33:08.053707+00	2025-06-13 13:33:08.052433+00
65110a89-6b47-4f87-a87a-120abb19a0be	4827c055-e066-4006-b8f6-d299d2689318	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:08.052433+00	\N	\N	bow	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:33:08.053707+00	2025-06-13 13:33:08.052433+00
90daf021-ce02-4b9b-8028-337b21fea66e	679de23c-c9e2-4670-9f58-1c34787c0c26	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:33:37.868265+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:33:37.869423+00	2025-06-13 13:33:37.868265+00
75350ed5-7d29-4122-a8d6-76daa6eb633a	6e39f6ac-2d34-4348-9ecf-42104afc890c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:34:37.002358+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:34:37.004715+00	2025-06-13 13:34:37.002358+00
e19933e8-3c18-41ba-bf53-434022ca88c4	e35a4023-41ab-4276-84c4-411e0f71f6e8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:34:37.93396+00	\N	\N	dagger	16	160	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:34:37.934771+00	2025-06-13 13:34:37.93396+00
6f5465d3-6f68-4143-ab84-8fc0c3da0a08	558804d6-38b7-43b8-bf11-deaf6d808abc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:35:07.902247+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:35:07.903682+00	2025-06-13 13:35:07.902247+00
eee1d2b1-bc5a-4de1-af8e-f6936409e48e	8735383b-96af-4d15-8d87-8debf217d559	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:35:38.382688+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:35:38.383556+00	2025-06-13 13:35:38.382688+00
8a33a27a-16df-4aad-a24a-f9a74a408a4c	8f16acd0-7514-4986-aa14-a296781b9818	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:35:38.382688+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:35:38.383556+00	2025-06-13 13:35:38.382688+00
f1e45deb-eea0-4457-8e27-2cae4aac5ca9	aff8512d-b606-4f6c-82c0-d3d58f81427a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:35:38.382688+00	\N	\N	dagger	18	180	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:35:38.383556+00	2025-06-13 13:35:38.382688+00
38a306b5-9994-450c-ab81-db9cda5cd418	9d47dd54-de87-436c-a65f-5e4e1ab5174e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:36:06.665486+00	\N	\N	staff	29	253	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:36:06.666429+00	2025-06-13 13:36:06.665486+00
5539c78f-cfb9-45f6-a934-6f1721cb564c	1c0e5617-862d-4476-b93e-dff458f4eb9d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:36:06.665486+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:36:06.666429+00	2025-06-13 13:36:06.665486+00
978c10c8-2905-4bbd-a080-f5fdc96f81fd	ed64454e-8515-4642-801e-51903fd0a5ed	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:36:06.665486+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:36:06.666429+00	2025-06-13 13:36:06.665486+00
f7865a05-8079-461a-b9c6-923764a89f48	e29ea075-3a55-466e-91e5-e97c4b76b9dd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:36:36.597777+00	\N	\N	bow	32	480	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 17:36:36.598922+00	2025-06-13 13:36:36.597777+00
4b44bf6c-afcd-4dd3-beba-8d4855743792	3ab1e68c-a945-40e2-9d19-a26f42de9d1a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:36:36.597777+00	\N	\N	staff	16	93	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:36:36.598922+00	2025-06-13 13:36:36.597777+00
9725fd05-9839-4e05-8475-6275efe34a01	7af10224-fb0c-4cd1-80a0-4bcfa5b5fe0a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:06.62982+00	\N	\N	dagger	16	160	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:37:06.630901+00	2025-06-13 13:37:06.62982+00
31831f49-7596-4bab-a26f-c4d1040f491f	20a6aa23-6c80-4c0e-ba18-2de6083f00dc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:06.62982+00	\N	\N	staff	15	87	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:37:06.630901+00	2025-06-13 13:37:06.62982+00
d51d2cbc-42a7-4713-833a-fc995863af49	ff14fcae-f89f-4a8b-84a7-00ff830c143c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:27.740509+00	\N	\N	staff	26	227	common	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:37:27.741479+00	2025-06-13 13:37:27.740509+00
42a79ce0-ca53-4b87-bb50-065efd44f145	77184551-8dac-48fa-8f9e-d8f17388acb6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:27.740509+00	\N	\N	dagger	30	450	common	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 09:37:27.741479+00	2025-06-13 13:37:27.740509+00
d953f8f4-18c7-40b2-8d86-260d7faa721a	fecfd674-43e6-4bb4-a05f-8be1a431cb8e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:27.740509+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:37:27.741479+00	2025-06-13 13:37:27.740509+00
58e1946c-45c1-4757-9307-26b57a837aed	de2fde5b-e34d-4aed-8b92-5cc826a1878c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:34.384454+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:37:34.385845+00	2025-06-13 13:37:34.384454+00
e5099b3c-79b2-46d2-903f-39d5ee35bd50	9fe5599b-e30e-48d2-86fb-3c62198bacf0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:34.384454+00	\N	\N	staff	15	87	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:37:34.385845+00	2025-06-13 13:37:34.384454+00
e5e16c3d-e9e0-40cf-879e-366ca3f05765	35774f59-8f33-48e8-96e2-5b9e15a5641d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:34.384454+00	\N	\N	bow	18	180	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:37:34.385845+00	2025-06-13 13:37:34.384454+00
5b63dda3-608a-4abb-a744-dc5a79142567	514571d9-c491-425b-91ea-26ca71b97ab8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:36.627991+00	\N	\N	staff	17	99	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:37:36.6292+00	2025-06-13 13:37:36.627991+00
11ddeb4c-768b-4146-962e-87dcd99fb38a	7107970f-de2d-4d5f-aa93-bb9385fd6761	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:36.627991+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:37:36.6292+00	2025-06-13 13:37:36.627991+00
6451e538-0ef3-494a-8ca5-37b898a6c5c2	d04e45db-8023-48ac-84b0-b10438f81154	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:37:36.627991+00	\N	\N	staff	18	105	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:37:36.6292+00	2025-06-13 13:37:36.627991+00
63f8aee9-5240-4930-a287-e56caaeb6080	c2975fc4-18ae-441b-b9b8-a3be7e597e02	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:06.544533+00	\N	\N	dagger	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:38:06.545467+00	2025-06-13 13:38:06.544533+00
b8cf97d2-dc70-4650-a2f3-63e7bafa3151	e86cb420-73ab-427d-9354-1f5c4f2bf5bf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:06.544533+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:38:06.545467+00	2025-06-13 13:38:06.544533+00
3c113fb2-a653-4648-beb4-d570fb7f3df7	9d3ffc05-5298-4f52-b2f1-0af17a76d9e6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:06.544533+00	\N	\N	bow	26	390	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 10:38:06.545467+00	2025-06-13 13:38:06.544533+00
e9539365-f049-4fa2-a959-028d84730d9e	a22f1690-1463-41cb-a668-1ba13bbdcd57	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:36.902393+00	\N	\N	bow	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:38:36.903673+00	2025-06-13 13:38:36.902393+00
4466f549-1be6-491d-8728-923271b34f50	f53a0731-ad96-470c-abe0-0b0afa70f571	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:36.902393+00	\N	\N	bow	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:38:36.903673+00	2025-06-13 13:38:36.902393+00
d852733a-4065-4ac2-b2a3-64d8fbc90dda	03a66652-7d50-4570-b7c7-9f7695233747	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:36.902393+00	\N	\N	dagger	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 16:38:36.903673+00	2025-06-13 13:38:36.902393+00
8fd3ae7f-e60a-45ff-a352-e25798bc74eb	abf3c73c-5b94-4961-bcd8-d2b09c14b174	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:38:48.416019+00	\N	\N	bow	26	390	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 22:38:48.416979+00	2025-06-13 13:38:48.416019+00
472453b7-1e18-4a81-b8e2-19520448caca	f3230f98-50e5-4421-ae80-5b67c3d4b6ce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:39:06.518564+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:39:06.519512+00	2025-06-13 13:39:06.518564+00
53cd5ff3-7c19-4f2b-bb80-be955b76a043	8fb5bbb3-cc59-4082-9b76-27b55b811a3f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:39:32.463893+00	\N	\N	bow	31	465	epic	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:39:32.46587+00	2025-06-13 13:39:32.463893+00
13c2effa-129d-4f35-ac59-3c301b487aae	4230949e-918d-4290-a49e-62d407587b12	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:39:36.613057+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:39:36.614295+00	2025-06-13 13:39:36.613057+00
d5822c4a-8a79-4044-945f-549456685ca3	d5033b71-a37a-4b45-8459-28e893d2a31b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:06.609856+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:40:06.610818+00	2025-06-13 13:40:06.609856+00
b492869d-646d-42d5-a12f-9bfdd5b02bdf	6dd7a709-1fe3-4ceb-8828-3ce5a372cadc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:06.609856+00	\N	\N	staff	19	110	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:40:06.610818+00	2025-06-13 13:40:06.609856+00
1c5f0495-0fff-463e-b9a8-f94da9b0a37d	cd119c51-920c-41a8-bd4a-c95c06d5990c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:27.502036+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:40:27.503475+00	2025-06-13 13:40:27.502036+00
401c1d69-6293-494d-abda-1102cce2fad8	b739efec-f0c4-4d66-a920-6c4362b94e40	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:27.502036+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:40:27.503475+00	2025-06-13 13:40:27.502036+00
c52b9c1d-7f10-4611-b3e4-cade563c23c1	a55028d5-6d13-4114-a618-161f6103d119	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:36.537322+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:40:36.53822+00	2025-06-13 13:40:36.537322+00
d19a7409-352c-49e5-8982-bf017e1745ef	b7152b70-dc8f-4105-8f16-a3a88f41dd87	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:36.537322+00	\N	\N	bow	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:40:36.53822+00	2025-06-13 13:40:36.537322+00
b75f7a36-5c81-4214-8259-a37002868657	5b0b3f75-a565-4a54-a0cc-090a76c349a4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:40:36.537322+00	\N	\N	dagger	17	170	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:40:36.53822+00	2025-06-13 13:40:36.537322+00
d5032a3b-4307-47a0-8ac2-b1ae8d30e045	7c5f88e6-f93e-4e38-80e9-deb7c7a94e4b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:41:06.506637+00	\N	\N	bow	15	150	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:41:06.507668+00	2025-06-13 13:41:06.506637+00
47ca1e59-fc1b-47cc-a3b2-d3f89b1d6e08	bbe65a08-5167-44fb-8bb0-426dca0d8200	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:41:06.506637+00	\N	\N	bow	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:41:06.507668+00	2025-06-13 13:41:06.506637+00
eff42234-5e8a-473f-a60c-18ef81e98ee6	fa939190-b9d8-44d0-8247-6522c7f7b25c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:06.566782+00	\N	\N	dagger	16	160	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:42:06.567859+00	2025-06-13 13:42:06.566782+00
c0647c19-fc63-4f21-8c6a-0d10b658c21f	e772d699-1502-4ab2-a429-93e8b16dedef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:06.66654+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:43:06.667604+00	2025-06-13 13:43:06.66654+00
fb6b50fa-0e50-4eb6-af44-4b1de263e730	668c1ae7-7e17-42c5-901e-498a54911358	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:06.66654+00	\N	\N	dagger	26	390	epic	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 09:43:06.667604+00	2025-06-13 13:43:06.66654+00
a6259455-0f9d-4bf7-a989-bfaa7c13b284	678ac050-fa95-493f-a5c5-51e02bd5b430	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:06.578828+00	\N	\N	dagger	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:45:06.580487+00	2025-06-13 13:45:06.578828+00
697e2f33-a22a-4ca0-aa57-1ee2a8ec6958	0bd7a8e1-8beb-4e3a-9625-9e209a3dc1df	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:06.578828+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:45:06.580487+00	2025-06-13 13:45:06.578828+00
5d1c142a-01a1-44f1-96bd-a5b3de254859	10e941a3-13b6-4abc-b265-d2fa00a9e7cd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:41:36.561295+00	\N	\N	bow	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:41:36.562233+00	2025-06-13 13:41:36.561295+00
d751ed17-85cc-46a5-9994-69eaf074cb94	7c2dd7f0-7e05-400f-8517-fa2912a4a751	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:44:06.621963+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 16:44:06.623625+00	2025-06-13 13:44:06.621963+00
1e926cde-0236-49d5-a564-732f68da42f1	af81e77f-827d-4ab1-b1db-46d7aad27f25	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:44:06.621963+00	\N	\N	dagger	15	150	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:44:06.623625+00	2025-06-13 13:44:06.621963+00
f81c93c0-1be8-430e-8c28-c892b09edd8c	53997c6f-8637-4a74-87f0-3087f2f24bb6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:46:36.568034+00	\N	\N	staff	26	227	common	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 04:46:36.569328+00	2025-06-13 13:46:36.568034+00
efd0fef4-ff10-4434-8399-e21b9ab7e76a	6b803dfe-a930-45c8-8289-3a76acc94632	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:46:58.148535+00	\N	\N	staff	18	105	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:46:58.149965+00	2025-06-13 13:46:58.148535+00
5cdcb216-e4a8-44eb-a806-6b788b7e6181	a8ba27fa-aab2-48c6-9339-ff102107adb4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:07.242425+00	\N	\N	dagger	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:47:07.24344+00	2025-06-13 13:47:07.242425+00
ea33d84e-b529-4db2-9e4f-d11fac66d4a5	b8912832-21eb-4115-8ec1-4109f8300c54	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:07.242425+00	\N	\N	bow	27	405	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 20:47:07.24344+00	2025-06-13 13:47:07.242425+00
1f247b58-edc2-41f1-a8e5-1b0f00ee21ee	ba150299-fd31-46b2-91ac-fdc07e4ef65d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:07.242425+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:47:07.24344+00	2025-06-13 13:47:07.242425+00
7503865d-c352-4438-af20-033fc0e18b6b	9c6bffd9-433e-49b0-a413-243e63611e50	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:14.565884+00	\N	\N	staff	17	99	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:47:14.56699+00	2025-06-13 13:47:14.565884+00
1918b1d6-8c36-4a9e-9cb2-d8a8a8fe11d3	b900cf30-64ad-4949-a816-bc309d47cda4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:14.565884+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:47:14.56699+00	2025-06-13 13:47:14.565884+00
ab1b229c-110e-48f2-8491-f2eeea8ddb92	4e710d27-99e8-4128-bd01-db90f9ee54ed	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:18.531172+00	\N	\N	staff	25	218	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 02:42:18.531996+00	2025-06-13 13:42:18.531172+00
a2d6cc17-56aa-4b97-9f0a-84c4697c1046	ea5b9637-64d6-4f22-80f3-a0b88e2eef33	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:18.531172+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:42:18.531996+00	2025-06-13 13:42:18.531172+00
f6b7b666-de20-4a1f-827c-e355925028c5	a91666fa-81d6-4b6f-a6bd-44c2311389f3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:18.531172+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:42:18.531996+00	2025-06-13 13:42:18.531172+00
3c2b8b06-9bed-49a0-b0f3-5acb07b63a88	8a0fbed9-d9a2-4957-b3ce-68e82431d87e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:36.576548+00	\N	\N	staff	27	236	common	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:45:36.578258+00	2025-06-13 13:45:36.576548+00
98f1650f-5f0a-4dcd-a461-0a077df93107	36810ec7-afe0-47bc-a241-4107ec59a5a3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:36.576548+00	\N	\N	dagger	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:45:36.578258+00	2025-06-13 13:45:36.576548+00
575f0bfb-d48d-4853-b9c1-65d2ba9ff405	151ce65b-052c-4e05-953f-4dd2de5adb85	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:36.576548+00	\N	\N	bow	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:45:36.578258+00	2025-06-13 13:45:36.576548+00
d6762cab-ed91-482e-bfcf-3306504fa9da	c19f05ac-325c-4a16-817f-f5bf77b59c09	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:46:47.668924+00	\N	\N	staff	29	253	common	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:46:47.670422+00	2025-06-13 13:46:47.668924+00
a8ac3b10-b6d0-4860-a559-223b809310e2	244d4867-fad2-44a4-aa5a-375e422c3a69	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:46:47.668924+00	\N	\N	staff	31	271	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:46:47.670422+00	2025-06-13 13:46:47.668924+00
f0287d3a-6922-47e3-a834-d97a5d7af12f	a28087d3-875b-4cc9-b992-cf486759f6c2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:36.53506+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:42:36.536302+00	2025-06-13 13:42:36.53506+00
0ccc9232-7f05-48f6-a4b4-8f2bc445dffe	4cfb14ee-53dc-442a-9cbd-fd887f0a12a5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:36.53506+00	\N	\N	staff	19	110	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:42:36.536302+00	2025-06-13 13:42:36.53506+00
25af75dd-288c-44e6-acce-42de5fec42c9	08f11f1b-2fff-4073-9452-f27154dfe7a3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:42:36.53506+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:42:36.536302+00	2025-06-13 13:42:36.53506+00
cf5614e7-ff4b-484e-ac63-200559145176	49bfadef-0bba-4330-b949-a6cee325540d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:34.59385+00	\N	\N	dagger	18	180	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:43:34.595186+00	2025-06-13 13:43:34.59385+00
85293b50-ff77-4c82-9bc5-f7fac0e78759	52dff9a1-234f-422e-8dcc-6fd618260976	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:34.59385+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:43:34.595186+00	2025-06-13 13:43:34.59385+00
f4564347-a56d-43a9-9c72-596981b3e180	16dfa871-4020-4a3f-a9dd-345a78da5a39	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:34.59385+00	\N	\N	bow	26	390	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:43:34.595186+00	2025-06-13 13:43:34.59385+00
43a47cd2-68c8-45b2-ad66-46fb4e7fc0e8	00168550-5fb6-4e70-84ee-9330970d737d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:36.566204+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:43:36.567068+00	2025-06-13 13:43:36.566204+00
8e90dc47-fcc9-4bfc-905a-89b81bae4558	af05dc7d-f50f-4c63-972d-8fcdd0b675be	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:43:36.566204+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:43:36.567068+00	2025-06-13 13:43:36.566204+00
9a186c7e-1c5a-4523-9ef2-ed02981a2149	5c848661-7500-4655-a719-cbe72350106e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:44:36.5578+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:44:36.559033+00	2025-06-13 13:44:36.5578+00
28361a77-12d2-4030-b872-88796a39b8e1	a5e505c4-4132-43e0-8756-37a7d5de1073	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:44:36.5578+00	\N	\N	bow	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:44:36.559033+00	2025-06-13 13:44:36.5578+00
23b806cf-8071-47b0-9063-2d0cf73eed5c	608c14d2-ad22-4969-a43d-fe9850a9d3d3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:44:36.5578+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:44:36.559033+00	2025-06-13 13:44:36.5578+00
880ee13c-a447-47b2-b072-514661119aff	4e9df8d7-a1f7-4be0-be3a-0c63d24aba9a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:45:10.644127+00	\N	\N	bow	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:45:10.645943+00	2025-06-13 13:45:10.644127+00
7a559764-3c50-4a26-87a3-7506abe47cec	2f3e7d79-09cb-4a09-8808-26d059aeb6bf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:46:06.623819+00	\N	\N	bow	19	190	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:46:06.624881+00	2025-06-13 13:46:06.623819+00
da25cdc4-f7ac-4e77-ba22-631c9cd65ca5	7ebbc6ef-c65b-48a0-996f-0bcfaabaedc3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:28.333134+00	\N	\N	dagger	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:47:28.334203+00	2025-06-13 13:47:28.333134+00
f0adca02-af26-4f0e-a0b0-e743b9b0509e	56867303-90ed-4ef6-898b-b9b5c0a087b4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:28.333134+00	\N	\N	dagger	16	160	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:47:28.334203+00	2025-06-13 13:47:28.333134+00
6d4ca3b8-2007-4ba1-a3a2-16782ccd31bf	b7097fdb-1ff7-4351-a8be-2ed021243bc6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:28.333134+00	\N	\N	dagger	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:47:28.334203+00	2025-06-13 13:47:28.333134+00
885f78d8-7e61-4b6f-977b-b23f2d73068a	7cb00101-52f1-453b-ad02-86714b1a2c14	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:53.917939+00	\N	\N	staff	17	99	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:47:53.919065+00	2025-06-13 13:47:53.917939+00
95ffc092-1906-48d1-801f-ee849318a4bc	94a833bf-4e5a-485d-a716-a8a3936d2280	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:53.917939+00	\N	\N	staff	18	105	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:47:53.919065+00	2025-06-13 13:47:53.917939+00
d96f9cde-1649-403b-a146-f2cbea049dd1	66bfdcdb-32cf-453c-b40e-894aa55b2517	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:59.656519+00	\N	\N	bow	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:47:59.657637+00	2025-06-13 13:47:59.656519+00
22ab1786-9533-4f2b-8943-3f811d8a2c17	bfd38e52-535c-4e1e-b4b9-b30253abad6f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:59.656519+00	\N	\N	staff	18	105	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:47:59.657637+00	2025-06-13 13:47:59.656519+00
c68ec689-b16d-4a0c-a187-a790ae3e9428	b77bdaa1-766f-4c86-8dad-5e36ba256e21	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:47:59.656519+00	\N	\N	bow	18	180	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:47:59.657637+00	2025-06-13 13:47:59.656519+00
c5efe3ba-b8ef-40d5-b138-5ff27918de14	ff433774-aa68-40fd-b76f-ef438b6b874f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:09.667971+00	\N	\N	staff	17	99	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:48:09.668892+00	2025-06-13 13:48:09.667971+00
b7830e30-83da-46fd-a7a4-1cb837c34a6d	b2c14248-390b-421b-9e30-0a7b43855699	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:09.667971+00	\N	\N	dagger	27	405	epic	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 20:48:09.668892+00	2025-06-13 13:48:09.667971+00
41f29809-eaea-49fe-ba64-8307a8621f2a	9449de98-1b2e-4d41-b15d-98d8c4c7b36f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:09.667971+00	\N	\N	bow	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:48:09.668892+00	2025-06-13 13:48:09.667971+00
1188ad5e-35a7-4d1e-905e-db9bfb99e048	adcd20ef-a4d4-4e9a-b3cf-22a24e36d1ce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:26.522181+00	\N	\N	staff	15	87	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:48:26.523696+00	2025-06-13 13:48:26.522181+00
27487f95-1d12-42f0-b144-ffcc5baaf4f0	754de84c-dafb-429c-ab54-53120b47ddce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:26.522181+00	\N	\N	bow	30	450	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 07:48:26.523696+00	2025-06-13 13:48:26.522181+00
912d27d1-186a-4ea2-a9b4-c2ba20eef02e	735ee245-92b3-4c7e-8a6d-70301bc8cf43	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:27.216026+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:48:27.21718+00	2025-06-13 13:48:27.216026+00
a345cdcd-f08b-4c7d-bf00-7952d56281a7	e1f5b601-a9af-4962-83fa-7f24bacbf892	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:27.216026+00	\N	\N	staff	15	87	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:48:27.21718+00	2025-06-13 13:48:27.216026+00
b42746b7-1555-49e3-96d2-70c1b1a21326	7fb0c0db-00d2-4b13-8e25-bd9874a0efa1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:27.216026+00	\N	\N	bow	18	180	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:48:27.21718+00	2025-06-13 13:48:27.216026+00
90c65c3b-52e7-4c70-adfb-90635d37d3ef	5fbe56d5-0274-46d9-830a-5a587b9b2dd0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:48:51.689208+00	\N	\N	staff	18	105	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:48:51.690134+00	2025-06-13 13:48:51.689208+00
c98d7006-794f-45ab-98b0-24af01802fc6	ce4c156d-99b0-4714-b33b-ed0c3b8b9082	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:17.257385+00	\N	\N	dagger	17	170	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:49:17.259096+00	2025-06-13 13:49:17.257385+00
ac4c405a-5bb6-4997-a9b3-cd07ba358585	31810352-0459-4d44-9e30-85ac620e21dc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:17.257385+00	\N	\N	staff	17	99	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:49:17.259096+00	2025-06-13 13:49:17.257385+00
101f9ad9-98ff-45f2-9b38-f17fe00f8e5d	3e0b6297-2820-45d4-b97d-5128e8e4b6b0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:21.37397+00	\N	\N	dagger	15	150	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:49:21.374936+00	2025-06-13 13:49:21.37397+00
03acee29-200e-4ae4-a127-94ac0aae2264	4bada1a2-0e3a-4219-a090-60b6589240b1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:21.37397+00	\N	\N	staff	17	99	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:49:21.374936+00	2025-06-13 13:49:21.37397+00
e40910a0-341d-4cc3-b5ae-35e2f58cbca3	89238c9b-c241-4c80-b1c0-416c1df5f06e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:21.37397+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:49:21.374936+00	2025-06-13 13:49:21.37397+00
ca3cb308-c79c-4f55-969b-6ac2993ccced	f6261809-e04e-4d7e-8097-3d2bd2d05181	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:51.364196+00	\N	\N	staff	17	99	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:49:51.365196+00	2025-06-13 13:49:51.364196+00
a86e5b4f-c9fb-44e7-ac10-bdb2ec611a93	b5f68624-8364-4265-a4a9-e9cfae932dce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:51.364196+00	\N	\N	dagger	28	420	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:49:51.365196+00	2025-06-13 13:49:51.364196+00
4c4e7c6b-bbc3-454a-9d93-68891b8cd13a	1af04060-bd0b-4d6c-9f3a-3d77cbc26c47	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:49:51.364196+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:49:51.365196+00	2025-06-13 13:49:51.364196+00
3297a232-7ca9-4687-9820-2f261767129c	8d7ec874-6f8f-4d14-abf3-4286be556d9a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:21.352779+00	\N	\N	staff	18	105	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:50:21.354072+00	2025-06-13 13:50:21.352779+00
37c5312e-80f9-47b7-a484-d25740d15661	140cb959-2a8f-42a3-aa48-3b20ce7a0718	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:21.352779+00	\N	\N	staff	19	110	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:50:21.354072+00	2025-06-13 13:50:21.352779+00
538681e4-0411-4a77-9774-e462bc41c282	9e18cb9f-400a-47e3-8983-afb7198d1f71	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:21.352779+00	\N	\N	staff	17	99	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:50:21.354072+00	2025-06-13 13:50:21.352779+00
838295c4-17e7-400f-bcb9-fee0d1095969	1be27b7e-397d-4e44-9910-87314b5985be	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:33.287071+00	\N	\N	staff	15	87	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:50:33.287926+00	2025-06-13 13:50:33.287071+00
8af7661f-6d77-4ed4-859a-07e6da26622b	a78b0549-a730-45fb-853a-e44d4d3d637c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:33.287071+00	\N	\N	dagger	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:50:33.287926+00	2025-06-13 13:50:33.287071+00
78b9a0a2-e6fa-47ca-a71b-cfb69ab80528	329179c5-8ec7-4aa4-b3af-db6ff973dc94	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:50:51.445576+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:50:51.446443+00	2025-06-13 13:50:51.445576+00
79b53de1-2195-4783-98f0-2e4ba070ac8d	f538145a-868f-4c7b-b6d5-9c5ec9943759	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:51:21.683562+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:51:21.685253+00	2025-06-13 13:51:21.683562+00
2b62fb6a-b174-4b9d-946e-ab6e2eb73468	37abc9f7-8520-4528-9fd9-004a43c62dfd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:51:21.683562+00	\N	\N	staff	16	93	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:51:21.685253+00	2025-06-13 13:51:21.683562+00
1ef556e9-3b17-48a3-94d3-8bda885562f7	4aa10c01-d17a-4db2-8315-138aefcda0e8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:51:51.640254+00	\N	\N	bow	17	170	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:51:51.641014+00	2025-06-13 13:51:51.640254+00
8b02634c-9e26-4766-96c4-a938327b6846	77abb9f6-80f0-44bd-84dd-faa364ef991c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:52:21.366202+00	\N	\N	bow	17	170	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:52:21.367129+00	2025-06-13 13:52:21.366202+00
659192b3-3e77-4edc-9522-daad4ff4e83b	a376f487-8ad4-4ef3-8e2a-01832585313e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:52:21.366202+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 17:52:21.367129+00	2025-06-13 13:52:21.366202+00
3792d213-b329-4a14-acc1-60295a44a1c8	854699dc-4955-4278-b905-29c200c06a97	\N	\N	0	0	1	normal	\N	pending	2025-06-13 13:52:21.366202+00	\N	\N	bow	16	160	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:52:21.367129+00	2025-06-13 13:52:21.366202+00
b6284781-3a9c-4540-9e4c-6d4e360aa519	c200d548-c6c9-49fa-a882-a4a21b0fe8f3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:52:11.507496+00	\N	\N	dagger	19	190	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:52:11.511626+00	2025-06-13 14:52:11.507496+00
62d692d0-2ea6-4592-a50a-d71f7c467c2e	f5ca47db-98c8-48f7-bb5c-f1ca469a4ce2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:52:11.507496+00	\N	\N	staff	16	93	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:52:11.511626+00	2025-06-13 14:52:11.507496+00
205d7a65-d11d-4564-8d2e-56389df46095	14416038-43d7-4485-bf28-9ec0dc0d7b81	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:52:11.507496+00	\N	\N	staff	31	271	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 09:52:11.511626+00	2025-06-13 14:52:11.507496+00
0635ce81-7cdd-4e06-ba51-31d4613d12d4	a3ba4e80-f072-4c81-ba39-9d5d0014fd1d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:52:17.889381+00	\N	\N	bow	29	435	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 19:52:17.891031+00	2025-06-13 14:52:17.889381+00
e3f724be-21a8-41c9-8bce-f8b503d638fc	37b0fbb5-1967-4d60-8a3b-cdc246358d99	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:52:41.014487+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:52:41.015536+00	2025-06-13 14:52:41.014487+00
b9884e98-0eb1-416e-bcdf-04565728522e	fb5828f1-98b3-4d1a-9225-724f8f658038	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:11.003486+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:53:11.005567+00	2025-06-13 14:53:11.003486+00
f8de5bd5-0246-4e38-bfad-e9e66c767a3d	d7f2ba36-4e5e-42ba-b9d7-dde01e59f8b7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:11.003486+00	\N	\N	bow	15	150	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:53:11.005567+00	2025-06-13 14:53:11.003486+00
6ca84b42-eb35-4c1e-911e-a18667f6cdca	8945b14f-7290-48d7-8a31-a425c02e268e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:11.003486+00	\N	\N	dagger	17	170	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:53:11.005567+00	2025-06-13 14:53:11.003486+00
e0f71e92-2e39-41ad-aaaf-2fbdde54a4d8	59257724-f18e-43a5-a7e7-ac15322ec921	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:15.88957+00	\N	\N	staff	17	99	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:53:15.890654+00	2025-06-13 14:53:15.88957+00
be6c8113-bc49-4cb7-b99c-d4d138657b02	c2062369-3cba-4a8c-9e11-814843f36c9c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:15.88957+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:53:15.890654+00	2025-06-13 14:53:15.88957+00
5e8dd8e3-9438-4eaf-84bc-85d50be96538	e43c4cb2-5562-40b1-82f6-1984fcdcc8cd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:15.88957+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:53:15.890654+00	2025-06-13 14:53:15.88957+00
c8852c1c-dfc2-443c-aa31-b69ee3b932bb	334e2d03-9a58-4df1-99ae-130f6c866abf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:41.052279+00	\N	\N	bow	18	180	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:53:41.053304+00	2025-06-13 14:53:41.052279+00
0e0a2be9-a582-44bb-af3b-7a3bade36f2f	6c193338-a8b1-4292-8e46-5c12aad365ba	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:41.052279+00	\N	\N	staff	25	218	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 12:53:41.053304+00	2025-06-13 14:53:41.052279+00
697bced0-60b8-48e5-a62d-2259a36df74a	8817810f-dc3b-412e-8e4b-fd09e8c7cdd1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:53:41.052279+00	\N	\N	staff	17	99	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:53:41.053304+00	2025-06-13 14:53:41.052279+00
a12fb36b-a957-4f5d-8497-111a03b80c99	630852e3-521c-4794-b8ac-665fb01c73e6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:11.060116+00	\N	\N	staff	26	227	rare	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 21:54:11.061265+00	2025-06-13 14:54:11.060116+00
fb93f57f-2f46-48eb-8e0a-86e76f17e96f	0b100c6b-b32b-4912-bc00-e0b180d1e32f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:11.060116+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:54:11.061265+00	2025-06-13 14:54:11.060116+00
055d622a-0b5d-4fb1-926a-cd2a4c00a37f	daec4287-2148-4b20-9346-f6ba9a9f2e6c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:11.060116+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:54:11.061265+00	2025-06-13 14:54:11.060116+00
0355bf93-4291-4c29-80a9-278a9e5f5bea	4700c907-5a56-4b4d-9756-d72a46def8e4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:20.94282+00	\N	\N	staff	18	105	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:54:20.944994+00	2025-06-13 14:54:20.94282+00
6fc1604c-4559-4b4a-b2bb-41622d56aedd	c0e56d49-9085-4405-b8a8-090b83bbbebc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:20.94282+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:54:20.944994+00	2025-06-13 14:54:20.94282+00
c964e8c6-f0b3-4f24-a512-b92f3986693c	49a4a909-76c7-4000-bdd4-554d3c05aef6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:54:41.490573+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:54:41.49191+00	2025-06-13 14:54:41.490573+00
98c2060a-324d-450a-a133-f4ae62ecb321	d937e3ad-b651-42a3-8f66-3b0f89830a40	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:02.992851+00	\N	\N	dagger	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:55:02.994263+00	2025-06-13 14:55:02.992851+00
e1bc72d9-b841-45e8-88e4-671933b47791	148f348a-7fc7-4dba-b5a6-212494d9da82	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:11.034093+00	\N	\N	staff	19	110	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:55:11.035379+00	2025-06-13 14:55:11.034093+00
98faf324-2d3c-4a37-81f9-fd8fbff84df0	01e8492d-2b62-43f5-8632-c9ea97fd5496	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:11.034093+00	\N	\N	dagger	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:55:11.035379+00	2025-06-13 14:55:11.034093+00
a271c123-0310-47e8-b4f6-a482e93a24e8	20234835-bcb8-41ca-8b04-d04bc8c3f13e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:11.034093+00	\N	\N	dagger	28	420	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:55:11.035379+00	2025-06-13 14:55:11.034093+00
4955dadc-5d5e-4b25-9198-efe1e8d4d00f	00d6cbc3-4780-4426-9cd3-e7092f3ce743	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:43.446091+00	\N	\N	bow	19	190	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:55:43.447742+00	2025-06-13 14:55:43.446091+00
fe62311d-5a2c-4c21-8db9-401fdfdf5873	3cac6b84-b5f9-40c7-94fd-64f25f8e3cb5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:43.446091+00	\N	\N	staff	25	218	epic	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 01:55:43.447742+00	2025-06-13 14:55:43.446091+00
22cdacee-8b11-4384-b45c-da3c6c3b7fdd	266a77a6-599e-49f4-96b6-3848d8e294c4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:53.941771+00	\N	\N	staff	17	99	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:55:53.943896+00	2025-06-13 14:55:53.941771+00
463107f6-e846-4688-9790-619c9f0252c3	86835666-fa3e-4d7e-a93a-7b39fba6791f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:53.941771+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:55:53.943896+00	2025-06-13 14:55:53.941771+00
ccf88d69-de09-42a6-8c58-c16878182b9c	6d95a44d-0a20-43b3-b165-9e8b1674afb3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:55:53.941771+00	\N	\N	staff	16	93	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:55:53.943896+00	2025-06-13 14:55:53.941771+00
2f83b6eb-790f-42cc-b5c8-4cf42ba32c11	c3f1bcfc-ae24-40eb-9095-dc2acddb960e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:11.06507+00	\N	\N	dagger	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 14:56:11.066695+00	2025-06-13 14:56:11.06507+00
be30fb2c-39fe-400d-b279-ae5da636daba	a0d28466-fead-4c42-84a2-2f57a178e04f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:40.248153+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:56:40.253572+00	2025-06-13 14:56:40.248153+00
c21f4a15-6135-4334-9590-383e257c0f72	140fd520-9016-491b-9ee3-038c189b3ab2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:40.248153+00	\N	\N	bow	29	435	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:56:40.253572+00	2025-06-13 14:56:40.248153+00
17c1a020-4af8-4511-9cdc-052d6f004df2	da327d64-481f-4f4a-a26c-db1c5427f820	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:40.248153+00	\N	\N	staff	31	271	rare	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 17:56:40.253572+00	2025-06-13 14:56:40.248153+00
32b959a7-8d2b-4694-8946-879bf432a250	164fd77e-2b7c-480a-ae1a-756815ad7213	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:45.242081+00	\N	\N	bow	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:56:45.245354+00	2025-06-13 14:56:45.242081+00
fbbb897b-41bf-4503-bb84-d41f44927164	a8c1d712-eb4f-4dd0-87eb-91648f1746d2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:56:45.242081+00	\N	\N	dagger	16	160	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:56:45.245354+00	2025-06-13 14:56:45.242081+00
36d2aae0-6c9e-4c13-b86f-c6a22eadec7c	c2c68564-9951-4b61-96b1-6df30530d8d3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:57:11.166491+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 17:57:11.167617+00	2025-06-13 14:57:11.166491+00
732ea5b1-257f-41b6-95a9-f14c5eae9016	58cfdde6-8b34-41be-a54e-6f80116dba8b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:57:11.166491+00	\N	\N	staff	19	110	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:57:11.167617+00	2025-06-13 14:57:11.166491+00
3210c01b-8212-4b91-9659-49a3d696c4e9	aa6b6f3c-1746-4215-84cd-ad14f81fee06	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:57:11.166491+00	\N	\N	staff	27	236	rare	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:57:11.167617+00	2025-06-13 14:57:11.166491+00
c8fa019a-e4a2-4340-be08-9aa1f7d968da	a573bcc4-be05-4323-8641-febc18b00c69	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:57:41.365407+00	\N	\N	staff	30	262	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 21:57:41.366403+00	2025-06-13 14:57:41.365407+00
fd6f1917-6106-4f71-81ae-ef0fa0265962	f248d0c1-8f6e-4948-8f04-3edd1a0fb3ff	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:58:11.065207+00	\N	\N	staff	15	87	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:58:11.066405+00	2025-06-13 14:58:11.065207+00
afe9fb18-604e-4776-9ad8-00eb4784869d	0be44b63-4a32-43a7-b468-7a2fa752e239	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:58:11.065207+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:58:11.066405+00	2025-06-13 14:58:11.065207+00
93c3bc66-ffee-454a-b5d5-267f5fbc557a	96058d0d-f579-4464-9677-22b4cb24e7eb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:58:41.010659+00	\N	\N	dagger	19	190	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:58:41.011871+00	2025-06-13 14:58:41.010659+00
e3fb137a-731c-441c-abe9-0aa0b9f751d5	102667d5-a780-4cb7-9320-feb9978f19cc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:58:41.010659+00	\N	\N	staff	26	227	epic	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:58:41.011871+00	2025-06-13 14:58:41.010659+00
4a9e5329-113e-4691-9bce-b98d73ab5894	cef0b1a6-42cd-4663-9abd-1a4824d70dbb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:59:04.615797+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:59:04.617715+00	2025-06-13 14:59:04.615797+00
6ad63418-842f-4526-b9ae-29a0aa2bbe4d	b37d95ce-4e8f-4574-a6da-f79c97034018	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:59:41.34368+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:59:41.34485+00	2025-06-13 14:59:41.34368+00
be88e855-b8f7-418a-a5de-1554f776a633	a6796745-d780-463b-a65e-086be1d37dce	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:59:41.34368+00	\N	\N	bow	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:59:41.34485+00	2025-06-13 14:59:41.34368+00
e603ea83-dc0a-4529-8ce0-7ab655fe5940	74f8d5df-d6b3-4c2d-9cd7-83f46af7c01e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 14:59:41.34368+00	\N	\N	dagger	18	180	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:59:41.34485+00	2025-06-13 14:59:41.34368+00
1e70f9c8-4673-4f87-8beb-9c711819bf8f	4ea339ec-c485-4cd7-abda-2cd0a2fbf96a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:11.040766+00	\N	\N	bow	25	375	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 13:00:11.042166+00	2025-06-13 15:00:11.040766+00
889bc7ae-a506-49e5-ba8d-42dae3a8aff4	276d1ab1-2255-4c4f-add3-460dab4f5550	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:11.040766+00	\N	\N	staff	18	105	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:00:11.042166+00	2025-06-13 15:00:11.040766+00
677f86c3-0b42-435e-8862-626fbbbd377f	59024cdd-6b3a-4deb-93bd-bbf0e95f052c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:11.040766+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:00:11.042166+00	2025-06-13 15:00:11.040766+00
74ae1968-65c4-4554-a65a-df72ae1323f8	1cb2d18b-f41c-4b54-953c-b1a152edf055	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:41.019809+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:00:41.021097+00	2025-06-13 15:00:41.019809+00
9afa3855-d472-4df5-8b87-2f1f1bca2d3b	4717a884-cc3b-4ac4-ba64-78fc18abc03f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:41.019809+00	\N	\N	staff	19	110	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 15:00:41.021097+00	2025-06-13 15:00:41.019809+00
8c416a2c-0fe4-426b-85bd-5b03e6191320	f4ca7cc4-8726-4914-a07b-d3af5c4a5f2e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:51.654212+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:00:51.655359+00	2025-06-13 15:00:51.654212+00
322feed2-220f-4b58-a387-8ba9e7971ee0	d7a2b71e-5e2a-4faa-832e-6921ddd18cc3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:51.654212+00	\N	\N	bow	32	480	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 22:00:51.655359+00	2025-06-13 15:00:51.654212+00
403dd606-4f27-42cf-9aef-d6a64bba1e4a	0cd6c2bb-20f3-44bd-b05f-164da352a05f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:00:51.654212+00	\N	\N	bow	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:00:51.655359+00	2025-06-13 15:00:51.654212+00
38ed3373-59bf-4f1b-8410-9aeaba165572	b18edf47-4bfb-4f2a-9ad6-74bcd8603166	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:01:11.056125+00	\N	\N	bow	19	190	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:01:11.057025+00	2025-06-13 15:01:11.056125+00
419b802b-7d3d-48d0-b0f2-5de6f302e28f	aa9bd696-7d86-4585-8ee9-ff5493ba74a2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:01:11.056125+00	\N	\N	dagger	27	405	epic	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:01:11.057025+00	2025-06-13 15:01:11.056125+00
fc9f0bbd-b080-45ba-b8e1-8c36477a17c4	36898a9a-7de4-49d9-b679-f957fb97dcc6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:01:41.019052+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:01:41.020051+00	2025-06-13 15:01:41.019052+00
80e782e5-c45c-4c00-bc15-3c9c73866fa4	3605d873-e3c0-4ca2-9dcb-721d56fa5c16	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:01:41.019052+00	\N	\N	dagger	18	180	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:01:41.020051+00	2025-06-13 15:01:41.019052+00
e553c761-ccf6-4bfc-80cc-347a6c62c916	42755314-ea14-48a7-9fe8-2fb10b2fc956	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:01:51.695661+00	\N	\N	bow	32	480	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 08:01:51.696776+00	2025-06-13 15:01:51.695661+00
5082d3af-f849-4497-aafd-fc6f2234d47e	e8d71621-4795-4c5f-ab2f-9d2a2eb3234b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:02:11.017665+00	\N	\N	staff	30	262	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 19:02:11.018758+00	2025-06-13 15:02:11.017665+00
bcd49bd9-dea1-47fc-b76d-d0e2ca714381	8f4cfc1d-1b90-4f4b-930a-16be4dd9dc57	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:02:11.017665+00	\N	\N	dagger	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:02:11.018758+00	2025-06-13 15:02:11.017665+00
7380a799-4c28-494b-8a32-1a343ec73a93	8fdf6bf3-573b-4a1e-9b26-fd42e9422c9f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:02:11.017665+00	\N	\N	dagger	17	170	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:02:11.018758+00	2025-06-13 15:02:11.017665+00
54ce5fb4-d7bc-4bd8-8a78-95c156f404b4	033c9001-eae2-4aa1-991c-9b4d7055f297	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:02:41.047184+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:02:41.048024+00	2025-06-13 15:02:41.047184+00
d5e75629-c9d4-4fb6-a481-46517802abb4	8afb6970-cf34-4896-91ac-65bf3868d4ee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:02:41.047184+00	\N	\N	bow	17	170	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:02:41.048024+00	2025-06-13 15:02:41.047184+00
cab7f14a-6473-4ead-bded-bb4892f548a5	0b45ceea-d5b2-4927-81c4-bbfb4b7aefe0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:03:11.03542+00	\N	\N	bow	30	450	common	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 22:03:11.036538+00	2025-06-13 15:03:11.03542+00
a4fb5e2d-35d5-486c-8363-d7f5ce44d8a8	3178e71a-6444-4bf7-9dac-f73c29ab4e1f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:04:31.946705+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:04:31.947757+00	2025-06-13 15:04:31.946705+00
60b61be0-885b-4c16-a245-71147ed04e7d	06c858fd-3df6-4b77-8683-470f6fa55380	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:01.668754+00	\N	\N	staff	32	280	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:05:01.669875+00	2025-06-13 15:05:01.668754+00
b0de5db3-ff4f-4695-a407-18c703e8794b	9fdeaf61-e443-463d-a359-b718cf0639ca	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:01.668754+00	\N	\N	dagger	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:05:01.669875+00	2025-06-13 15:05:01.668754+00
2c00d2d6-951c-4aa3-8d5a-cc87e30eb8a4	37670a51-426c-4e63-8f62-2c007c0e61f8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:01.668754+00	\N	\N	bow	18	180	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:05:01.669875+00	2025-06-13 15:05:01.668754+00
6a9a3a09-0e9b-4dc1-96a0-acd3182d7610	29e62f6e-c891-4e90-9940-08a016d3b350	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:06.592298+00	\N	\N	bow	19	190	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:06:06.593218+00	2025-06-13 15:06:06.592298+00
15aa002f-6750-40e5-ae5d-c93a62811703	c21ec8c6-4450-4230-827c-77d76a210adb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:06.592298+00	\N	\N	bow	15	150	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:06:06.593218+00	2025-06-13 15:06:06.592298+00
62ab17f5-8ec3-481c-b008-f09e98aedf55	104a1819-4a24-4918-aad3-4aae3b686e3c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:06.592298+00	\N	\N	staff	15	87	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:06:06.593218+00	2025-06-13 15:06:06.592298+00
67249252-115a-4aef-af47-e4bf92a7f3bc	90e0b226-55c0-4a12-98a0-5e42884c96b8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:38.761829+00	\N	\N	bow	29	435	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 20:06:38.762712+00	2025-06-13 15:06:38.761829+00
6da5654e-3f12-4a79-a494-6ff66eae974e	dcbb2b34-b79b-439c-9807-733f4c1df3d1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:38.761829+00	\N	\N	dagger	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 15:06:38.762712+00	2025-06-13 15:06:38.761829+00
1b659e5f-9c51-420e-a38a-a769c4d2ba8e	74875282-b631-4542-8244-9c86be129ba3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:00.62791+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:07:00.629439+00	2025-06-13 15:07:00.62791+00
6fa2d5ec-99e8-49b2-a472-5418a305ef5a	882c7fe0-830d-45ce-a8c1-6b5035ff3db8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:00.62791+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:07:00.629439+00	2025-06-13 15:07:00.62791+00
dde3ae9e-acac-4450-bbca-528fbc23e363	3cede37e-9408-4d27-bebd-5a5b8962fb19	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:08.747228+00	\N	\N	staff	16	93	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:07:08.748471+00	2025-06-13 15:07:08.747228+00
62a8d51b-8afd-43d9-aa4e-909540479b16	52847b81-4bbf-4c20-9642-6dfa4ce26cd7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:08.747228+00	\N	\N	bow	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:07:08.748471+00	2025-06-13 15:07:08.747228+00
5efae341-f1e5-4429-a3cf-d36242f8cc81	0f597f4e-176c-4820-b98e-f57ba9622654	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:18.29464+00	\N	\N	bow	25	375	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 06:08:18.295862+00	2025-06-13 15:08:18.29464+00
4d5a0893-8fb2-4978-b1b2-84ea2cecd1ae	731106de-3537-484f-8326-d5c6ac0fdb0d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:18.29464+00	\N	\N	staff	28	244	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 13:08:18.295862+00	2025-06-13 15:08:18.29464+00
d392cd56-7b07-4242-950d-bdd1384f4b65	c3fc7135-3fe3-43a5-b54f-fef7b1853ace	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:51.458931+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:08:51.460052+00	2025-06-13 15:08:51.458931+00
533171b4-a1c4-49ee-93d5-086b1d7c7254	bb614c73-0cc3-4354-856d-94ace94000c7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:09:52.416593+00	\N	\N	dagger	31	465	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 18:09:52.418036+00	2025-06-13 15:09:52.416593+00
2e09ef86-dfe7-4554-8c23-65a94d7b3502	cdf0b605-ff60-4b15-aace-914cc192b5f0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:10:51.443548+00	\N	\N	dagger	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:10:51.444421+00	2025-06-13 15:10:51.443548+00
e6a0097c-5b6d-44a3-8e1b-500247b7b74e	6eb87d89-4e52-41e9-ad09-972b3ef0a20f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:10:51.443548+00	\N	\N	bow	26	390	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 05:10:51.444421+00	2025-06-13 15:10:51.443548+00
d01a3051-399f-48b8-81f4-d542e6dfbfc9	10759c3c-7302-41d0-956c-c05deba3a807	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:21.543041+00	\N	\N	bow	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:11:21.543944+00	2025-06-13 15:11:21.543041+00
0967441d-98a7-4ca3-a603-1a7e650bb46e	2b1b57df-854c-4ab9-a3ce-721cf7bd4428	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:21.543041+00	\N	\N	dagger	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:11:21.543944+00	2025-06-13 15:11:21.543041+00
35a71a9b-9bdf-4ad8-ba95-b3e98b3e2d5d	cfea3ae0-bdee-4b84-bcb1-07234f56b8e0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:21.543041+00	\N	\N	staff	26	227	rare	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 19:11:21.543944+00	2025-06-13 15:11:21.543041+00
1956bff8-1ab4-4980-afad-cee06a167a8e	be8853dc-9921-496d-a8fa-ada6041f6762	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:51.61936+00	\N	\N	bow	25	375	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 13:11:51.620331+00	2025-06-13 15:11:51.61936+00
a1ca7254-58db-4a62-8bfd-458226fd58a5	c28c954b-9f5f-4261-bedd-2d4eb5744722	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:51.61936+00	\N	\N	staff	17	99	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:11:51.620331+00	2025-06-13 15:11:51.61936+00
591e1bff-a1e9-4f33-bea0-d48c88d8ab97	dda78d2d-9c95-4f10-ba27-838bbeba188d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:51.61936+00	\N	\N	dagger	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:11:51.620331+00	2025-06-13 15:11:51.61936+00
d55bb439-0e51-4084-b0b7-3def17856b05	29838871-09d6-47fc-a8b1-2f0e6c7ec95f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:03.632809+00	\N	\N	staff	18	105	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:13:03.633588+00	2025-06-13 15:13:03.632809+00
e78ac703-a128-4938-856d-2c4217da3832	7813d1d2-4609-4bf6-936c-cfedc8553505	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:03.632809+00	\N	\N	staff	18	105	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:13:03.633588+00	2025-06-13 15:13:03.632809+00
c8cb51ed-ea7f-4c3d-b635-45f923dbc75e	66a86992-49c7-4fb8-8886-549a08f333c8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:15:21.552848+00	\N	\N	dagger	25	375	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:15:21.55377+00	2025-06-13 15:15:21.552848+00
f9b4b517-31e4-4a31-98d1-c95171e323e6	dd7c083a-0f4e-40a0-a2b4-db731974fec0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:17:33.974485+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:17:33.975485+00	2025-06-13 15:17:33.974485+00
7726a132-3427-4613-bc49-7925b95c760f	74810878-2e39-4219-96d0-9f2a2ae15ecf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:17:33.974485+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:17:33.975485+00	2025-06-13 15:17:33.974485+00
792ebaae-8732-46ec-baa4-ec8311bc06e4	5f5b750b-d588-49c5-b954-6c361066de3d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:22:34.003784+00	\N	\N	dagger	15	150	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:22:34.004765+00	2025-06-13 15:22:34.003784+00
29c1d498-0489-40b0-bd35-a869fe60640c	fd050aee-3e37-47a8-96e2-75351c96c094	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:23:37.995696+00	\N	\N	dagger	31	465	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 20:23:37.997245+00	2025-06-13 15:23:37.995696+00
adc02cab-07ce-4021-a31d-243bd421d130	11fb75f7-6d5c-43fe-aeca-d470728b7178	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:23:37.995696+00	\N	\N	staff	27	236	common	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 08:23:37.997245+00	2025-06-13 15:23:37.995696+00
9c55f22a-467c-4fc2-a1bc-ddc096c3d064	39ce3904-47c1-45a0-ab4a-2ff62ecd7449	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:09.099215+00	\N	\N	staff	17	99	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:05:09.100986+00	2025-06-13 15:05:09.099215+00
1b0c60f3-5d72-436e-b612-083b91bf30d9	3fafe14f-0a52-44d5-bd74-d5d7263309ea	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:09.099215+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:05:09.100986+00	2025-06-13 15:05:09.099215+00
5bf6c090-b762-4b69-a8de-c41b530149c1	c184c344-6621-4cbd-bf5f-ec264f04b786	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:09.099215+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:05:09.100986+00	2025-06-13 15:05:09.099215+00
42142989-f4ef-442d-8bb0-4a3041e101ad	42818db1-ea86-4c34-b5ba-4b0dc31139d2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:25.662027+00	\N	\N	dagger	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:05:25.662992+00	2025-06-13 15:05:25.662027+00
c82ff712-2ae8-4c11-a4be-2f8923ae410d	b67451fd-af44-495a-8051-b4d49be380d9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:38.751453+00	\N	\N	staff	27	236	common	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 10:05:38.752474+00	2025-06-13 15:05:38.751453+00
58bc749c-7321-490b-aeae-d0c7fe0f248a	1a3c6620-6ebd-4bc3-a6ea-f701663f9a96	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:05:38.751453+00	\N	\N	dagger	26	390	common	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:05:38.752474+00	2025-06-13 15:05:38.751453+00
557f2428-db00-4b79-9cc1-6076282e2ffb	5ef72eda-64d9-4e06-912e-b3c10a3409bf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:21.443559+00	\N	\N	staff	26	227	epic	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 15:08:21.444847+00	2025-06-13 15:08:21.443559+00
7e1a61ea-e1eb-4fb8-96fe-1f26c1204135	0652f999-99f8-45e7-a55c-7705257063db	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:21.443559+00	\N	\N	dagger	18	180	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:08:21.444847+00	2025-06-13 15:08:21.443559+00
2ff86516-fcda-43d9-a4f1-deef0bda4120	3617f225-274d-4077-a771-57ca31521794	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:21.443559+00	\N	\N	bow	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:08:21.444847+00	2025-06-13 15:08:21.443559+00
5dda870b-405f-4279-8125-230e3b7d6330	59b7a923-1daa-4557-a115-87e370898b42	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:10:21.455386+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:10:21.456126+00	2025-06-13 15:10:21.455386+00
637471fb-b240-4530-b56e-9784e3d9ad2b	b35b768a-ab4c-477c-85f3-a984c1ca305e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:10:21.455386+00	\N	\N	dagger	19	190	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:10:21.456126+00	2025-06-13 15:10:21.455386+00
ef086406-3000-42f6-9f2c-1e6b0b087339	038525a7-3de2-4616-8ca5-22f86e34bd3d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:12:51.557882+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:12:51.558625+00	2025-06-13 15:12:51.557882+00
983c322a-53a4-475a-bb20-a7b4561c1f11	27eb2ad2-a0cf-47cf-a9d2-914ee0d80bfa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:12:51.557882+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:12:51.558625+00	2025-06-13 15:12:51.557882+00
9c7bf0f0-77c6-45d2-a601-155fa33d5d7b	d3035bfb-97c2-40b1-bc11-d867dcb81501	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:14:02.6649+00	\N	\N	bow	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:14:02.666021+00	2025-06-13 15:14:02.6649+00
79e81e7e-bb16-4c17-893a-c21d332c88d3	8cb2870c-ff83-473f-8808-f3c951be0e6a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:14:51.533694+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:14:51.534672+00	2025-06-13 15:14:51.533694+00
351bb388-82ea-4f8e-bd89-dcf1654bcff1	b0b7008f-c448-4abc-b67b-5f8bbb8b5372	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:16:21.543129+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:16:21.565312+00	2025-06-13 15:16:21.543129+00
df6e2e86-67a4-46d3-b84d-9b6f423ad9b1	11c3f2f2-d2c3-4b91-a083-9307a072585b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:52.812068+00	\N	\N	bow	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:18:52.813122+00	2025-06-13 15:18:52.812068+00
6be0e9ec-7d82-472e-919b-5caf349bfaea	b148a6aa-6ad9-4333-87d0-2c8e66979b96	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:52.812068+00	\N	\N	dagger	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:18:52.813122+00	2025-06-13 15:18:52.812068+00
bda87018-38ee-4969-aaec-b5f537487efa	f1a38c54-833b-4b23-8c47-9bf1ada978b5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:19:42.838041+00	\N	\N	bow	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:19:42.839386+00	2025-06-13 15:19:42.838041+00
21b5484c-01a2-4a1d-a30b-34184e63cac6	170bbe65-1bbf-4e9e-b0f1-69f1081a7833	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:21:04.010536+00	\N	\N	staff	18	105	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:21:04.011492+00	2025-06-13 15:21:04.010536+00
0cbd2699-5f85-4ef6-8c0d-bb50d0f23c0f	6ef8190d-2671-4805-994e-c4d3c8beedef	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:22:03.976323+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:22:03.977083+00	2025-06-13 15:22:03.976323+00
0ad4c1d7-333d-4ee2-900f-7744b56180d8	b6c0be7b-1f52-4081-92fe-4948d545f950	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:23:04.139882+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:23:04.141624+00	2025-06-13 15:23:04.139882+00
42f64d4d-7582-40b6-8990-2eb5ac36626c	a1b6032e-ca46-4e4a-85d8-2eb8c3374a82	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:23:04.139882+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:23:04.141624+00	2025-06-13 15:23:04.139882+00
ed378d04-50f4-4657-80b9-fdc46c8f9ee3	7b5c71c8-9fc1-4aa6-8f95-4bd64b0e4971	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:06:08.801061+00	\N	\N	dagger	15	150	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:06:08.801863+00	2025-06-13 15:06:08.801061+00
0cd983e7-c833-49de-8bd5-c97d9aade22d	7d002dd6-6629-42e3-a4d0-2f0ab0ee0f7a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:21.456221+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:07:21.458419+00	2025-06-13 15:07:21.456221+00
eea00203-2660-4413-b764-7fedbe16079a	5d2da451-1f47-41e1-8f86-bf439c7bc929	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:21.456221+00	\N	\N	bow	25	375	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 15:07:21.458419+00	2025-06-13 15:07:21.456221+00
8dc61d15-600e-4bc7-9083-66052e0f0db4	e2071218-b420-48b2-b8df-1d3fa48b7fb6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:51.460245+00	\N	\N	dagger	30	450	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 15:07:51.461166+00	2025-06-13 15:07:51.460245+00
705abedd-ca65-4c99-b8e7-16be1ff23064	c5b6ba45-1674-4a90-bcd9-5cae4a53251e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:07:51.460245+00	\N	\N	staff	18	105	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:07:51.461166+00	2025-06-13 15:07:51.460245+00
3f61425b-9c2c-4d53-b816-60ded7c93436	5f01f595-44bb-4d54-a098-5766df2e74f8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:57.351729+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:08:57.3538+00	2025-06-13 15:08:57.351729+00
608f41e3-f753-4ebf-b7a5-f669768334da	21aa774b-13f6-44ad-a6ce-09f919cbc8cd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:57.351729+00	\N	\N	staff	18	105	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:08:57.3538+00	2025-06-13 15:08:57.351729+00
bb574d52-8afd-40c5-b3a2-0c356bd27ecd	f0432ca7-b479-442e-b7f0-ed3a9bb63bea	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:08:57.351729+00	\N	\N	dagger	25	375	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:08:57.3538+00	2025-06-13 15:08:57.351729+00
aead6a7e-8b07-4339-98dd-36c431b5ed7e	ca88931a-afa9-4e51-bac6-3255643bf5a7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:09:21.493841+00	\N	\N	staff	25	218	rare	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 12:09:21.495405+00	2025-06-13 15:09:21.493841+00
113d9d52-23ab-4fa4-a6a4-d803ba6622b1	fb4ac901-ad18-4075-92bd-abbb1ecac180	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:09:21.493841+00	\N	\N	dagger	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:09:21.495405+00	2025-06-13 15:09:21.493841+00
990828ec-eaee-44a4-91b6-f5d54d24654f	ef78ca09-4fd5-4630-a23e-e0c1a88666c4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:09:21.493841+00	\N	\N	bow	15	150	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:09:21.495405+00	2025-06-13 15:09:21.493841+00
5d2550c6-7883-46d8-9c24-b59839b0f8d8	35d02b8f-1dd8-4c53-a499-a32c84a7286e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:09:51.480115+00	\N	\N	dagger	16	160	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 01:09:51.481783+00	2025-06-13 15:09:51.480115+00
3c3544d0-210f-44db-8d63-644414a23e6d	7c52963a-8e5c-49ec-b379-4194b2ce29eb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:31.576026+00	\N	\N	dagger	16	160	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:11:31.577432+00	2025-06-13 15:11:31.576026+00
e5b96758-8812-440c-9bc0-3bc766103d96	a193e1ad-d137-45bb-a9be-873e15845a53	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:31.576026+00	\N	\N	staff	31	271	common	5	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 13:11:31.577432+00	2025-06-13 15:11:31.576026+00
d16e5eff-f8b1-4e87-899c-60f563c00308	d389b6ff-a37e-4de1-8d8d-b7a0f5ffbb88	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:11:31.576026+00	\N	\N	staff	29	253	epic	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 19:11:31.577432+00	2025-06-13 15:11:31.576026+00
e41f352b-a5a1-4c41-978e-eeeae500e815	cdb250ec-bed3-46a3-a4e5-395ce4ab9cdf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:12:21.55577+00	\N	\N	staff	28	244	common	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 00:12:21.556589+00	2025-06-13 15:12:21.55577+00
51e34f6a-ab2d-42b0-9369-e96d1673ec7a	6cf23abb-0a01-42d4-90dc-3c89e3f46e8b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:21.574328+00	\N	\N	staff	26	227	epic	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 14:13:21.575437+00	2025-06-13 15:13:21.574328+00
cd5b0804-0617-485b-bfbe-37e671ae535e	7e0f2e19-5aec-4c1f-9799-fa84cee03b5c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:21.574328+00	\N	\N	bow	19	190	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:13:21.575437+00	2025-06-13 15:13:21.574328+00
23440f86-1eec-4b6f-90d1-3640db885961	bdd2ee2c-ecf7-44de-a621-04ccf9972b84	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:21.574328+00	\N	\N	staff	25	218	common	2	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 15:13:21.575437+00	2025-06-13 15:13:21.574328+00
38903b05-6ce0-48b0-b9ac-baa28ee225cd	cea9e029-329e-4696-b401-6770393003bc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:51.598084+00	\N	\N	bow	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:13:51.599024+00	2025-06-13 15:13:51.598084+00
445389f7-a6a3-45a0-9028-099655a9b46f	7067a43d-44db-4a84-ae2e-72494cc96f7e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:13:51.598084+00	\N	\N	dagger	26	390	epic	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 09:13:51.599024+00	2025-06-13 15:13:51.598084+00
78a1a440-7f20-422c-9a20-cef61758a18f	83636661-dc7d-496b-b756-9d89af09436a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:14:21.553374+00	\N	\N	bow	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 15:14:21.554248+00	2025-06-13 15:14:21.553374+00
2df6bd06-0e93-4824-8652-57cd44de6d2c	eadcf2b1-e075-4846-bd79-c4965032c682	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:14:21.553374+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:14:21.554248+00	2025-06-13 15:14:21.553374+00
38c678c0-e95f-4326-b5eb-aed9fcdb3c43	7b5d65dc-dcf9-495c-bb22-854d5d6692cf	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:15:39.68066+00	\N	\N	bow	15	150	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 23:15:39.682921+00	2025-06-13 15:15:39.68066+00
89974121-641c-4353-a39d-8527405b9caa	39987ec6-c15d-4fb5-85e5-33fa1b557279	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:15:39.68066+00	\N	\N	bow	18	180	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:15:39.682921+00	2025-06-13 15:15:39.68066+00
56a8d9a9-a457-47db-955e-b2bc651103d5	28a78291-6fd0-4014-8fc1-80f0a7898e61	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:15:51.566621+00	\N	\N	bow	18	180	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:15:51.567575+00	2025-06-13 15:15:51.566621+00
78ea1f4e-1985-44b5-bac2-494b3cd263ef	0c59d780-0d37-4025-96c7-2027a552a0fc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:15:51.566621+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:15:51.567575+00	2025-06-13 15:15:51.566621+00
a7618319-d161-4dd8-9b35-f771273eec24	91c53756-12f5-4966-90fe-d8b71b9568c0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:16:51.564004+00	\N	\N	dagger	17	170	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:16:51.565029+00	2025-06-13 15:16:51.564004+00
f4500dcf-bec8-4dde-a863-7a394fdc36b3	bbef1c63-ba44-4f9d-b8d2-ad5f19ce0a0a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:17:04.008447+00	\N	\N	staff	27	236	epic	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 06:17:04.009788+00	2025-06-13 15:17:04.008447+00
d46965ff-d595-4480-91c8-e7738e7d7e40	6bd14f11-b9c3-4467-a40c-c5273e74b76b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:04.110746+00	\N	\N	staff	16	93	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:18:04.112705+00	2025-06-13 15:18:04.110746+00
15f47654-ca6d-4e89-9def-f8b5347f09c1	8ee25b2d-a247-4dfc-a096-f7b324c1115d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:04.110746+00	\N	\N	bow	32	480	rare	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 11:18:04.112705+00	2025-06-13 15:18:04.110746+00
b0324385-a9fc-44f4-a840-e93a31414d10	2d4d612e-6f98-45fc-8a30-627e1ede542a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:04.110746+00	\N	\N	staff	16	93	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:18:04.112705+00	2025-06-13 15:18:04.110746+00
7d726fd1-dad7-4eb9-bfe8-0ceee492ed15	20a235a6-3276-47ab-b4ba-26d475985d8e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:18:34.036607+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:18:34.037576+00	2025-06-13 15:18:34.036607+00
bf926ced-133b-4983-bb7f-cf644b5d1916	c87a4d44-07c8-4cb0-ae3a-412aba30a941	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:19:03.974895+00	\N	\N	dagger	19	190	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:19:03.976152+00	2025-06-13 15:19:03.974895+00
bab37fb1-5318-4db1-a875-387595e03fad	dd4dbe6a-1fc9-4768-81c2-9b7e3fb70e15	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:19:33.992411+00	\N	\N	bow	30	450	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 05:19:33.993555+00	2025-06-13 15:19:33.992411+00
d7a733b3-a825-44ba-9a7c-56ffb8722689	195b0c06-3f63-4921-a5ca-e2943877788b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:19:33.992411+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:19:33.993555+00	2025-06-13 15:19:33.992411+00
ead066ff-0554-43c4-91ff-dbaf855c632c	06d26c3a-96d5-42da-80fc-15a058ba7602	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:19:33.992411+00	\N	\N	dagger	19	190	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:19:33.993555+00	2025-06-13 15:19:33.992411+00
fa1855c9-5814-4573-a488-be930955d30d	b8e72ffe-171d-4212-80b4-5d1e0124d76c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:03.973328+00	\N	\N	staff	19	110	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:20:03.974483+00	2025-06-13 15:20:03.973328+00
eda97ee5-81be-4f76-9429-6a3c0e03b4fd	2769cac9-7b48-4918-952d-3f2d7525fd67	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:03.973328+00	\N	\N	bow	31	465	common	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 10:20:03.974483+00	2025-06-13 15:20:03.973328+00
a8d5b0c3-44bb-498d-8c5b-048058ba0088	9841a412-1615-4c66-9c06-8a5210206ddb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:03.973328+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:20:03.974483+00	2025-06-13 15:20:03.973328+00
6ea14f8b-49f9-4e49-a9d0-eb3a8850460b	aef02420-16e0-47ee-a8d4-2570fe3a8195	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:21:28.881773+00	\N	\N	dagger	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 13:21:28.883092+00	2025-06-13 15:21:28.881773+00
8339f110-d6e1-4923-933b-a8a1a26ee8e5	b8a8a32d-5622-4f28-b6fb-85cc13c7ec20	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:21:28.881773+00	\N	\N	dagger	17	170	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:21:28.883092+00	2025-06-13 15:21:28.881773+00
1b4f16be-2ee0-47f7-81ae-5b9955740c45	93de4a8a-aca1-428b-b108-d9e5515a77d6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:22:25.929883+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:22:25.931245+00	2025-06-13 15:22:25.929883+00
e6b15e8d-7311-418d-83b6-c98eed9ad0af	14185f4c-ce43-415d-ae3d-b098609576c0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:22:25.929883+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:22:25.931245+00	2025-06-13 15:22:25.929883+00
d95ce5cb-b27e-45fa-bd9e-f5c35bf692c4	f04793a8-6c21-4ccd-b50a-775e1e3f8772	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:22:25.929883+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:22:25.931245+00	2025-06-13 15:22:25.929883+00
58fef56a-efd2-4e62-8d73-6f73456f374a	4d56693a-3877-4c57-8193-e131058e801a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:23:34.001154+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:23:34.002875+00	2025-06-13 15:23:34.001154+00
9b6823c6-8a85-42b7-9540-069d80bdb027	f4663dcb-883c-4b2d-aad1-91d67164b81f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:34.038198+00	\N	\N	bow	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:20:34.039803+00	2025-06-13 15:20:34.038198+00
bc39f358-4d1e-4732-9fb7-5fa132bd348e	2938c441-dbde-4d6e-8dbd-55bcc8ac9e29	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:34.038198+00	\N	\N	bow	17	170	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:20:34.039803+00	2025-06-13 15:20:34.038198+00
eb481668-03b6-41b3-902b-e820cc8acab9	21e1539a-614e-4418-9fbf-b0d678ed1da8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:20:34.038198+00	\N	\N	staff	31	271	common	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:20:34.039803+00	2025-06-13 15:20:34.038198+00
4cec207d-f91a-4e4a-ae5b-c8afe1efa2ec	fcd80279-5a5d-4a6e-8841-30d840242f9a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:21:33.986785+00	\N	\N	dagger	32	480	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 11:21:33.98782+00	2025-06-13 15:21:33.986785+00
1cd73979-ce53-419c-aceb-6a7012e36d36	42f19a24-e7b9-4fbf-a675-ca8931057057	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:24:03.970722+00	\N	\N	dagger	32	480	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 06:24:03.971565+00	2025-06-13 15:24:03.970722+00
968dd498-b669-4984-8085-98ffa2e4759b	6a550249-7b9c-401b-8056-577b7b616a85	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:24:03.970722+00	\N	\N	bow	26	390	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:24:03.971565+00	2025-06-13 15:24:03.970722+00
77673271-44d9-4a8b-a13d-7ee28059cd8c	231d8ea4-0bf0-4332-90a3-a6cb39304261	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:24:34.030619+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:24:34.031644+00	2025-06-13 15:24:34.030619+00
62f72132-cb95-480b-923b-0f0d6915f65f	e487549f-a22f-4f08-88b2-510718a4ca62	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:24:34.030619+00	\N	\N	dagger	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 22:24:34.031644+00	2025-06-13 15:24:34.030619+00
5478841e-71ea-4b9b-8e24-a91e313cce19	484489cf-d23a-4283-979a-7e5d589d5839	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:24:34.030619+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:24:34.031644+00	2025-06-13 15:24:34.030619+00
3fe22ba6-f0ee-4012-a167-fb46077d9966	33ade5ff-0be1-4693-a820-2912b87ae8b5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:02.029544+00	\N	\N	staff	19	110	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 10:25:02.030705+00	2025-06-13 15:25:02.029544+00
391d632f-8837-41ad-aecf-19e4cdd7b92b	90623cbf-f859-49fd-ae0a-6cf84a48f438	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:02.029544+00	\N	\N	staff	16	93	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:25:02.030705+00	2025-06-13 15:25:02.029544+00
21916a4d-9217-4c5c-bca1-7f18686f9e13	93199484-3df1-4ef4-9d0b-3b06c742721e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:02.029544+00	\N	\N	dagger	18	180	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:25:02.030705+00	2025-06-13 15:25:02.029544+00
11418092-f529-4087-9cec-0bb431656edf	d9ee3aed-66de-45f8-91b8-e3bf541d26b3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:04.002315+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:25:04.003306+00	2025-06-13 15:25:04.002315+00
77261747-4f12-4d50-aae0-6b4f8320d32b	558009a9-dde1-4be1-a1cf-c4c87a5293f1	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:33.967431+00	\N	\N	dagger	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:25:33.968422+00	2025-06-13 15:25:33.967431+00
51ce5236-9e16-45e6-b56a-0c40bd736725	591ae18f-42ba-424d-bfa2-45f41dba02e6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:33.967431+00	\N	\N	dagger	31	465	epic	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 14:25:33.968422+00	2025-06-13 15:25:33.967431+00
51a4d3b5-2080-4fe9-9efb-a94d7239ff14	252e164b-e263-4dd2-a93e-b771ee29c51a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:33.967431+00	\N	\N	dagger	31	465	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 15:25:33.968422+00	2025-06-13 15:25:33.967431+00
99d417c9-50a4-43fa-ad9a-346ff2e961d2	9aa33a07-87f3-4fcf-87f4-0399f064c181	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:51.062586+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:25:51.064114+00	2025-06-13 15:25:51.062586+00
2989db56-9bbc-4f55-b1df-677730f1a531	98441486-cffa-43d1-a62f-9ed3768bdee3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:25:51.062586+00	\N	\N	staff	18	105	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:25:51.064114+00	2025-06-13 15:25:51.062586+00
409f363a-5e7b-4914-9319-3ac090bbb104	fdc1a491-5b5e-4ab8-b223-8340b78b9278	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:26:03.954397+00	\N	\N	staff	15	87	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:26:03.955434+00	2025-06-13 15:26:03.954397+00
9f837ee7-6456-47ff-b8ef-84a37651576e	0abaf9dd-e487-4863-8e69-d07b817760ec	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:26:34.036585+00	\N	\N	staff	17	99	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:26:34.037871+00	2025-06-13 15:26:34.036585+00
8547240a-6d01-4c59-8112-56daf46361c6	c28c5bf0-e20f-49ae-995f-5864090329d9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:03.95847+00	\N	\N	staff	15	87	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 18:27:03.959486+00	2025-06-13 15:27:03.95847+00
492684ed-2474-491a-9ae5-8761e8416386	80b67976-23bd-49a2-a594-4b8d9126f6a7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:26.119011+00	\N	\N	bow	17	170	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:27:26.120503+00	2025-06-13 15:27:26.119011+00
8ee061b9-a8dc-4a56-ac31-958887ec16d3	8c71a344-c3c9-47d4-a002-d4e273cfea54	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:26.119011+00	\N	\N	dagger	15	150	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:27:26.120503+00	2025-06-13 15:27:26.119011+00
14b498b0-004d-4100-bcd1-b3d1658295ae	63d40969-c057-48d8-874f-ac2d2d721786	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:26.119011+00	\N	\N	bow	15	150	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:27:26.120503+00	2025-06-13 15:27:26.119011+00
51379585-709f-41ab-b4b7-d00947f91f58	2244eb5b-3217-41fc-b197-8b8aebe5a240	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:34.013103+00	\N	\N	bow	17	170	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:27:34.014081+00	2025-06-13 15:27:34.013103+00
146fbc76-2822-4011-b981-4cd7f540abc9	3e2dd72d-6786-4c2f-afd9-07a0464732c7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:27:34.013103+00	\N	\N	dagger	25	375	epic	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 10:27:34.014081+00	2025-06-13 15:27:34.013103+00
b4e72bf5-68f0-48d8-b713-f9de33a73daf	e7808757-0a4f-40ac-9e7f-0b2aa2ca1637	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:03.989595+00	\N	\N	dagger	17	170	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:28:03.990548+00	2025-06-13 15:28:03.989595+00
613b93f2-390c-4753-a9ab-9184bef44577	591f6b6b-0bb4-4c55-8462-a2aa97a30e74	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:03.989595+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:28:03.990548+00	2025-06-13 15:28:03.989595+00
2be917ac-58a3-4621-813c-32c920966e0f	486b175f-4161-421c-bf86-9efebe9a3e3a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:33.952938+00	\N	\N	staff	18	105	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:28:33.953941+00	2025-06-13 15:28:33.952938+00
f060825e-1761-4953-993d-20218594ac5e	056156a9-78c6-4471-a097-8c37c258c7ee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:33.952938+00	\N	\N	staff	17	99	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:28:33.953941+00	2025-06-13 15:28:33.952938+00
723f2b5b-86d4-4e73-9f25-a35106b84192	2e019e94-0858-48be-a713-4a506d28af12	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:55.176662+00	\N	\N	staff	28	244	rare	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 21:28:55.177831+00	2025-06-13 15:28:55.176662+00
6636ff6d-3500-4a37-83c0-28eebe9e6008	72c6ada9-5ebb-4516-bb81-8ffeb3871144	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:28:55.176662+00	\N	\N	dagger	27	405	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 19:28:55.177831+00	2025-06-13 15:28:55.176662+00
2e738f56-f898-41e7-9774-5d95b3ea642a	9e9b0322-5f6a-4942-80d2-80b4993f3b47	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:29:04.006647+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:29:04.00757+00	2025-06-13 15:29:04.006647+00
b36700af-43b8-425b-ae4d-542c8a078ff2	1f831890-3c94-48e2-89cf-294fb2e4c263	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:29:04.006647+00	\N	\N	dagger	19	190	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:29:04.00757+00	2025-06-13 15:29:04.006647+00
f2d64dcb-51d0-4b73-837d-4f8beeefe0f0	ac4ec242-8a2d-4b2a-8e1a-0b9aad13720d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:29:33.417456+00	\N	\N	staff	15	87	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:29:33.424148+00	2025-06-13 15:29:33.417456+00
ae6e814e-22ec-47b5-857c-4f6775870bdd	5c4f7576-4069-48dc-92ac-3667166bd15b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:29:34.051856+00	\N	\N	staff	17	99	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:29:34.052924+00	2025-06-13 15:29:34.051856+00
40127d33-a504-4241-93b8-0b72825e1611	41955d2f-5787-458e-8e10-dec9ddbff1b2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:29:34.051856+00	\N	\N	bow	30	450	rare	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 01:29:34.052924+00	2025-06-13 15:29:34.051856+00
c60635d1-ed7f-4182-9f0e-282d218803f0	7ab9cecb-369d-495e-a3f7-cdd814633b76	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:30:04.014388+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:30:04.015369+00	2025-06-13 15:30:04.014388+00
9af831f4-e951-4d27-9282-c9c216040cf8	e9f6ba84-b952-4578-bc03-ca4779987f96	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:30:04.014388+00	\N	\N	dagger	15	150	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 00:30:04.015369+00	2025-06-13 15:30:04.014388+00
a5d0a26c-0468-4942-a7bc-212bf782af8a	8f02addb-0a97-49c1-895e-236eb36c6fb0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:30:33.994104+00	\N	\N	dagger	17	170	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:30:33.995286+00	2025-06-13 15:30:33.994104+00
e05e3517-772d-429c-9faf-df67aecb8aa0	be939a78-7ac7-4c94-851d-68fbc3191047	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:03.960108+00	\N	\N	staff	27	236	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 11:31:03.961279+00	2025-06-13 15:31:03.960108+00
da9989a3-6f00-433e-bf7e-d382caf9e848	bfb4d0d4-0c16-4018-a1b8-71a117ba7d57	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:03.960108+00	\N	\N	dagger	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:31:03.961279+00	2025-06-13 15:31:03.960108+00
3ef69348-90d3-4a95-86eb-126fb8638079	2c5d2fd6-23e0-40c1-b769-ae345a224e35	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:03.960108+00	\N	\N	bow	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:31:03.961279+00	2025-06-13 15:31:03.960108+00
cbb70b09-b942-4d5c-b01b-94b014bc2646	f2b323b1-f6a6-488c-8097-e86e8fa0c405	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:19.77682+00	\N	\N	dagger	15	150	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:31:19.78006+00	2025-06-13 15:31:19.77682+00
aeec6d81-ac32-4430-8f69-70475e13865d	e0bf8f0d-4b8c-44ab-af7d-94bc52e60bac	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:19.77682+00	\N	\N	bow	27	405	common	4	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 15:31:19.78006+00	2025-06-13 15:31:19.77682+00
44dfbbe2-41d0-4bd6-9dbc-4dd9e2d59534	f6e66cff-4978-482b-9e65-2868f7287d77	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:19.77682+00	\N	\N	staff	18	105	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:31:19.78006+00	2025-06-13 15:31:19.77682+00
4143c7c0-f90d-4057-83da-036996a3642c	fe03c23d-51dc-46de-b5d5-2ec0d024e23e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:34.081186+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 09:31:34.082829+00	2025-06-13 15:31:34.081186+00
d04fcd17-9a16-4c81-a60a-82ffc4de4a75	902c0602-f1b9-470d-990c-11872662cf23	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:34.081186+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:31:34.082829+00	2025-06-13 15:31:34.081186+00
b607842e-1d22-44d9-90fd-eb2c0a225ed9	d7a7160f-843d-401a-88c6-6b8901c9da16	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:31:34.081186+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:31:34.082829+00	2025-06-13 15:31:34.081186+00
62999d2a-710a-43f4-8757-00e34c6f2810	0e907d4c-9213-4d07-be09-b912b7cbdf9b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:32:06.345937+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:32:06.346871+00	2025-06-13 15:32:06.345937+00
2390d23d-04e6-44f1-a87d-105d210d12ef	16795bfd-c7f2-4a2b-a3f2-c40b6908d087	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:32:06.345937+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:32:06.346871+00	2025-06-13 15:32:06.345937+00
acd75f62-87be-4a7d-9e71-2721b2abcdae	b44025e7-1dc7-481d-8306-82b1a46122fa	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:32:46.058344+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 03:32:46.060919+00	2025-06-13 15:32:46.058344+00
d2f5619e-4410-4a2c-9495-24f11fee8f3a	e7550e70-59a2-404f-83e7-b5a5be291135	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:32:46.058344+00	\N	\N	dagger	16	160	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:32:46.060919+00	2025-06-13 15:32:46.058344+00
57b42868-6180-4da5-a950-d9a8ca32dfe5	14d096ef-02d4-48c9-98d2-7a5c54039995	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:32:46.058344+00	\N	\N	dagger	26	390	rare	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 12:32:46.060919+00	2025-06-13 15:32:46.058344+00
d05d9186-1cc3-4549-b30f-6ad6661220af	925b500e-a331-46da-ac98-3300f456a42b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:33:04.052905+00	\N	\N	staff	16	93	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:33:04.053931+00	2025-06-13 15:33:04.052905+00
be391650-2d52-41d0-b99e-56e221ba70d1	21fcfc1b-d84b-4fe2-9d60-19dc7f358f99	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:33:04.052905+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:33:04.053931+00	2025-06-13 15:33:04.052905+00
8167983c-f399-4ee9-a36f-d5a3e8e321f5	340d42f3-d6b8-4935-b9ca-7d95e8f45fbb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:33:04.052905+00	\N	\N	staff	17	99	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:33:04.053931+00	2025-06-13 15:33:04.052905+00
503e61a0-141d-470d-8a4d-59ebd93314a4	6275ed53-6d6b-401b-8d4d-98286dae2b8f	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:33:34.285251+00	\N	\N	dagger	25	375	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 14:33:34.286236+00	2025-06-13 15:33:34.285251+00
9df53a0f-472a-401f-9942-fd76a7b7457b	42748848-8a3e-44b9-9889-ff5ac90cea24	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:33:34.285251+00	\N	\N	dagger	15	150	rare	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:33:34.286236+00	2025-06-13 15:33:34.285251+00
6b0d754d-ccff-489f-a799-319180b00da8	46a10921-cf0f-430f-a573-d5a3b6cddd77	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:04.013049+00	\N	\N	staff	19	110	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:34:04.014344+00	2025-06-13 15:34:04.013049+00
cc482140-835b-498b-aa08-2d9093489022	0be94227-0312-49bc-95a8-e62e805c9f75	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:04.013049+00	\N	\N	staff	19	110	rare	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 06:34:04.014344+00	2025-06-13 15:34:04.013049+00
f2df16bc-869c-4dea-ba61-641fee27e876	c8fb727d-a725-470c-aa7b-b5857041ffbc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:04.013049+00	\N	\N	staff	15	87	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 04:34:04.014344+00	2025-06-13 15:34:04.013049+00
0fb83297-125f-4359-9f8c-c2428bcf7a63	5f779222-9c4a-4b54-b480-090cbfd295d8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:06.122791+00	\N	\N	staff	16	93	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:34:06.123924+00	2025-06-13 15:34:06.122791+00
87c4eaab-96a8-4938-bb0a-b6749123df92	b2cbcade-4111-4260-9546-e3f068aebd77	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:06.122791+00	\N	\N	dagger	32	480	rare	2	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 18:34:06.123924+00	2025-06-13 15:34:06.122791+00
f1446a2a-86c0-4b4b-8ac3-144e21c7a7ac	38b4b075-b898-4608-bed8-91dcf5db7242	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:06.122791+00	\N	\N	staff	18	105	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:34:06.123924+00	2025-06-13 15:34:06.122791+00
fcd1a012-3c16-4e14-8e62-61c120603148	64b1d544-f1f1-48a8-a34e-4bba74cefa67	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:33.9975+00	\N	\N	dagger	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 20:34:33.998478+00	2025-06-13 15:34:33.9975+00
1cc122d3-abec-4541-9fe9-9a7631be5b7b	26c1a8d4-44fc-42a0-a35c-d00c667706c0	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:33.9975+00	\N	\N	staff	30	262	epic	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 02:34:33.998478+00	2025-06-13 15:34:33.9975+00
acd6320a-c214-4e39-81f8-000e5b2bf3f1	e8ebd75d-0d1d-4ad9-aaeb-351ee26f3d94	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:34:58.163967+00	\N	\N	staff	18	105	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:34:58.164961+00	2025-06-13 15:34:58.163967+00
ffc43edd-a281-4083-aa01-6b2bc2c96871	870c2893-b8b9-449c-9b46-22fdb42b2513	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:35:03.963841+00	\N	\N	dagger	18	180	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:35:03.964975+00	2025-06-13 15:35:03.963841+00
aaf24e84-8e8c-41fd-adf1-a2ab67d57b64	d575c319-ae06-4f62-8fe0-88f0f150acdd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:35:34.27587+00	\N	\N	staff	15	87	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:35:34.277415+00	2025-06-13 15:35:34.27587+00
8b52c9a0-7f3a-47a4-ad66-a1688f5d5182	dfd6416c-a68b-4579-b292-431e4da86dc8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:36:04.011312+00	\N	\N	bow	28	420	epic	1	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 00:36:04.012461+00	2025-06-13 15:36:04.011312+00
6e11af9b-fd3d-4f3f-bc6d-6dc6cbb90adf	7d5568d9-f3e7-4633-8e2d-9d7bcbcd5d89	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:36:34.286588+00	\N	\N	bow	15	150	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 05:36:34.287553+00	2025-06-13 15:36:34.286588+00
a1c248be-4f12-43f7-b584-960a87c0c42b	38aad4c0-17c3-4a57-a105-fa35884206a3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:36:34.286588+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 14:36:34.287553+00	2025-06-13 15:36:34.286588+00
61711ae2-faa4-4297-be3d-89b8713ee828	71df6c18-6a64-4bd1-af62-6b5c73edbfc7	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:36:34.286588+00	\N	\N	staff	19	110	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 01:36:34.287553+00	2025-06-13 15:36:34.286588+00
48603ffd-e970-41a9-9ce4-3d2c782421d8	f31fc57f-d5e3-489c-bd69-a550544eea13	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:36:49.188236+00	\N	\N	staff	19	110	rare	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 15:36:49.189512+00	2025-06-13 15:36:49.188236+00
6afde08b-9cb3-477c-a9c6-74b7a9332cf9	8f13fd1c-fc0b-4326-8fd6-0ecc291b15bd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:37:04.019699+00	\N	\N	dagger	17	170	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:37:04.020726+00	2025-06-13 15:37:04.019699+00
65acb2f6-cdca-467e-b5d5-0313870f8f15	766506d7-ebab-4e2a-adba-53ff6652cf8e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:37:25.246648+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:37:25.248403+00	2025-06-13 15:37:25.246648+00
1d59e947-fcb6-4b09-aea8-c1e2d6b8d60f	20f83d56-e7fb-48a6-bfb9-93f1339c8261	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:37:34.044751+00	\N	\N	staff	15	87	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:37:34.045608+00	2025-06-13 15:37:34.044751+00
93234c0a-eee8-42c7-b8a9-b09efd8b6166	7696893c-fc61-45ec-b905-6b073b39f925	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:37:34.044751+00	\N	\N	staff	28	244	common	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 14:37:34.045608+00	2025-06-13 15:37:34.044751+00
538fd03b-3a87-432f-bbab-e77845719a5e	ee56c49a-5043-4170-b9bd-d2b63aa304cd	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:37:34.044751+00	\N	\N	bow	16	160	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 14:37:34.045608+00	2025-06-13 15:37:34.044751+00
070eb858-2b22-4d45-9e4c-16da5366c9d6	0d59aa65-4446-4e98-92a8-da2c7b243dc9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:38:06.791231+00	\N	\N	bow	19	190	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:38:06.792662+00	2025-06-13 15:38:06.791231+00
41380f4c-3a24-4150-bf92-083d36f43992	80e4bfb4-6e9d-499f-a1a6-f06ab64616ed	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:38:06.791231+00	\N	\N	dagger	18	180	rare	3	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:38:06.792662+00	2025-06-13 15:38:06.791231+00
d6bf36f1-d106-43ad-b132-ea0e8a9c21bf	52872eca-3e3b-48f9-9f9e-774d3ed940cc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:38:06.791231+00	\N	\N	dagger	32	480	common	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-13 21:38:06.792662+00	2025-06-13 15:38:06.791231+00
16f83752-2b10-4c4b-bb09-506b190b85e1	4d0376a7-448d-4529-ab22-5600d6179f9d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:38:27.732002+00	\N	\N	bow	15	150	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:38:27.734124+00	2025-06-13 15:38:27.732002+00
4b6fc4f5-45ca-437b-ab58-148bc34512bc	b5b16c18-90d1-4a30-90ff-f616fc1558ee	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:38:34.122262+00	\N	\N	staff	17	99	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:38:34.123111+00	2025-06-13 15:38:34.122262+00
44e929d7-de87-4181-a9ed-8190171ec87b	e880e8e3-d911-407b-aa22-0ad3756bba82	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:04.278883+00	\N	\N	staff	18	105	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 00:39:04.280389+00	2025-06-13 15:39:04.278883+00
1614ba14-cd3a-4e68-9668-d2305e5f1744	95888d22-e9ad-43d5-ae3d-bd4f9805545e	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:04.278883+00	\N	\N	bow	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:39:04.280389+00	2025-06-13 15:39:04.278883+00
21ff92f4-a14d-4b32-b0f8-8813d614a9cd	b3446ac8-902f-4e5f-82c9-b47f55b9b643	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:09.769452+00	\N	\N	staff	19	110	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 21:39:09.77146+00	2025-06-13 15:39:09.769452+00
a5861297-8ad6-41bc-9b2a-15206d733394	38814b55-6a12-4ff0-b707-468015558589	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:09.769452+00	\N	\N	dagger	32	480	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 06:39:09.77146+00	2025-06-13 15:39:09.769452+00
72eebb75-4313-4cbd-a31e-1d6318aef3f1	682bfbd7-8a39-43f5-9c09-c0c2b651a611	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:09.769452+00	\N	\N	dagger	17	170	rare	4	【NORMAL】normalなarcherからのリクエスト	2025-06-13 21:39:09.77146+00	2025-06-13 15:39:09.769452+00
7d91571b-2322-4e57-8f6d-1b09122b18c0	e1c7769f-87de-4ba8-b60b-163a8afc7619	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:34.025269+00	\N	\N	staff	18	105	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:39:34.026014+00	2025-06-13 15:39:34.025269+00
824603e4-8279-4ed3-a37b-5e6f8d6bf0bc	5a9efa96-6e63-4f6f-ac83-ce86669b1f3c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:34.025269+00	\N	\N	staff	18	105	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:39:34.026014+00	2025-06-13 15:39:34.025269+00
5d62f6c8-7656-486a-ba8a-188da9de1627	504723be-b0b8-48e2-a531-5d4be8151d23	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:39:44.827136+00	\N	\N	staff	19	110	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:39:44.828833+00	2025-06-13 15:39:44.827136+00
fd0e06d9-8960-4fd0-9e20-2dfb89b01690	e1fcb4e1-f149-489e-aeb4-64100597c4f6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:40:04.021198+00	\N	\N	staff	26	227	rare	1	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 05:40:04.022184+00	2025-06-13 15:40:04.021198+00
6275673b-b36c-4c21-bbbc-4acf71bc3aad	c269d95c-4fcc-401c-b855-5d02d591e664	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:40:20.859561+00	\N	\N	staff	16	93	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:40:20.860338+00	2025-06-13 15:40:20.859561+00
33966a2f-d759-470a-84db-f1177d6b7f25	93310e81-5e99-42d0-8569-f10685e91ec3	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:40:20.859561+00	\N	\N	dagger	25	375	rare	3	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 03:40:20.860338+00	2025-06-13 15:40:20.859561+00
6a907454-16d7-45ba-a51b-ff85a679e0e2	996f2279-fd97-4f87-97d3-3b1fbb4823d5	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:40:34.031363+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-13 20:40:34.032214+00	2025-06-13 15:40:34.031363+00
dcacd9d0-6283-4cff-9620-d1520ff7f64a	96f24cce-04f1-4b09-8d28-881612181887	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:04.100034+00	\N	\N	bow	16	160	rare	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 02:41:04.101194+00	2025-06-13 15:41:04.100034+00
3eefc9cf-49eb-445e-9366-05614f0a5f5d	9737dd69-46dc-4cef-99be-78aa4c26b6e6	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:04.100034+00	\N	\N	dagger	16	160	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:41:04.101194+00	2025-06-13 15:41:04.100034+00
eaa3d02e-2bc0-4817-a566-abc77342670a	9257e774-0766-4a18-a7b4-43be81bf0cbe	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:04.100034+00	\N	\N	bow	19	190	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:41:04.101194+00	2025-06-13 15:41:04.100034+00
ed08ecae-b5cb-4e65-844f-90cdf63a9ee2	a1b689c8-48d6-4e3a-b404-a2bb96635598	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:26.903833+00	\N	\N	bow	18	180	common	3	【NORMAL】normalなarcherからのリクエスト	2025-06-14 06:41:26.90546+00	2025-06-13 15:41:26.903833+00
45548fc1-ab05-4a17-a4c9-7220f73c1093	39389860-c117-47a8-961b-766f35398459	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:26.903833+00	\N	\N	staff	16	93	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 23:41:26.90546+00	2025-06-13 15:41:26.903833+00
ab7aeb68-242c-46a7-aa3b-3ed2bb4a2df1	3fdaa29e-0e50-4c17-b05c-879eaa6951d2	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:41:34.05105+00	\N	\N	dagger	29	435	rare	5	【CHALLENGE】normalなarcherからのリクエスト	2025-06-14 02:41:34.052399+00	2025-06-13 15:41:34.05105+00
b285350a-08c9-4caf-80e5-468dbd9fd9d5	3729fae9-322a-4cfa-8ed4-81ee4bbc51f4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:04.35868+00	\N	\N	staff	17	99	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 05:42:04.36042+00	2025-06-13 15:42:04.35868+00
ff27a0e0-ccc0-4ce6-b785-0a8672a097fc	f76e834a-72c1-4432-a971-cfb30df022ae	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:04.35868+00	\N	\N	bow	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 04:42:04.36042+00	2025-06-13 15:42:04.35868+00
a1c2c0d9-d7fc-4b7a-bf10-652f5de12ff4	6a98fd87-9a59-4710-ac94-9fa333faf65d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:04.35868+00	\N	\N	dagger	16	160	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 15:42:04.36042+00	2025-06-13 15:42:04.35868+00
fff4d242-31a7-42e9-9d42-ca28da795168	e8aa2414-200c-46a1-a190-860e15e9957a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:34.111675+00	\N	\N	dagger	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-14 10:42:34.113475+00	2025-06-13 15:42:34.111675+00
13548f14-7601-4083-927a-65b526d6a861	713a3773-c802-4ddd-961f-0920d5e26b58	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:45.94097+00	\N	\N	staff	16	93	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:42:45.942255+00	2025-06-13 15:42:45.94097+00
ac17b26b-02cd-4665-bd12-04422bfdc0da	64091b7e-5a10-4ddb-baac-ace1075cb28c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:45.94097+00	\N	\N	staff	18	105	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 13:42:45.942255+00	2025-06-13 15:42:45.94097+00
4b4846eb-24fe-48af-b590-ccb239000cf2	301e8ec1-c736-4bc2-83d4-59d3f535c9e9	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:42:45.94097+00	\N	\N	staff	16	93	common	5	【NORMAL】stingyなmageからのリクエスト	2025-06-14 12:42:45.942255+00	2025-06-13 15:42:45.94097+00
3823ddfc-113a-4ca0-ad2a-a65acf1403c8	ab9ff744-6358-4317-8bb2-ee5c243eee33	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:04.071416+00	\N	\N	dagger	19	190	common	2	【NORMAL】normalなarcherからのリクエスト	2025-06-13 18:43:04.072536+00	2025-06-13 15:43:04.071416+00
243cacfb-fe22-4296-a312-d44575446bba	bba23de3-4cdf-4895-80c8-b4546cfe6df4	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:04.071416+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 09:43:04.072536+00	2025-06-13 15:43:04.071416+00
2bfeea6b-72cd-4eec-8d34-6dcfadcbc54d	a6db3b6e-36d6-4fec-be9d-654afa06c82c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:15.981961+00	\N	\N	bow	15	150	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 03:43:15.983097+00	2025-06-13 15:43:15.981961+00
004427e9-8094-4f1f-b0bc-ba4a551794df	ae3b1bf7-671f-441b-82b0-91301ec6b187	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:15.981961+00	\N	\N	bow	15	150	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 07:43:15.983097+00	2025-06-13 15:43:15.981961+00
74b2a408-8de0-4bcd-919d-cd34a5035e37	ff6e7d07-79c3-4bf2-ac52-67804a051d53	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:15.981961+00	\N	\N	staff	15	87	common	3	【NORMAL】stingyなmageからのリクエスト	2025-06-13 19:43:15.983097+00	2025-06-13 15:43:15.981961+00
a83a9e8b-61ad-4e69-ae75-c6a62375c0b0	fbfaad49-11da-4219-a4b4-6975e725e440	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:34.097824+00	\N	\N	staff	19	110	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 07:43:34.099266+00	2025-06-13 15:43:34.097824+00
95c455e2-0790-4763-85d1-22dce6d0984d	71ec2674-d1fd-449d-aca8-5fced2b455bb	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:43:34.097824+00	\N	\N	bow	19	190	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-13 19:43:34.099266+00	2025-06-13 15:43:34.097824+00
a13d014b-d876-4dd1-99d2-bff0c8d8c695	e03cee68-3b5d-44c8-8861-50a577b35a72	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:44:04.07339+00	\N	\N	staff	16	93	common	1	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:44:04.074763+00	2025-06-13 15:44:04.07339+00
fc5238ef-9235-4f79-a0e5-2b6d3592a197	30aa4980-9582-4a46-a76a-a62b710c6ee8	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:44:34.016074+00	\N	\N	staff	15	87	common	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:44:34.017377+00	2025-06-13 15:44:34.016074+00
11d80ec3-4a80-4432-9f71-2ee50f20cdf6	bb0c8af5-2013-4bb6-a82a-4c50f16c08cc	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:45:34.109703+00	\N	\N	staff	31	271	rare	3	【CHALLENGE】stingyなmageからのリクエスト	2025-06-14 03:45:34.11141+00	2025-06-13 15:45:34.109703+00
2ae926e0-e01f-4ddc-9291-a9436d0f3f04	82d74c60-eacc-453a-994c-9278be44b19a	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:45:34.109703+00	\N	\N	bow	16	160	common	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:45:34.11141+00	2025-06-13 15:45:34.109703+00
244cc902-1839-4ca8-9511-b755d829d012	1bb29d29-fa12-4fbe-9db2-e4b7da327417	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:46:05.099158+00	\N	\N	dagger	19	190	common	4	【NORMAL】normalなarcherからのリクエスト	2025-06-14 08:46:05.100213+00	2025-06-13 15:46:05.099158+00
fc1a418f-f90e-4ee9-ad98-4702e834a21b	1f479029-9d25-4af8-b3cd-cf9e2f8c7670	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:46:05.099158+00	\N	\N	bow	17	170	common	5	【NORMAL】normalなarcherからのリクエスト	2025-06-14 11:46:05.100213+00	2025-06-13 15:46:05.099158+00
555a4eed-b5a3-4ac8-ab1f-a804b0ff3c0c	0c032672-154f-4b6b-aef1-107ce35ca087	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:44:58.05523+00	\N	\N	staff	16	93	rare	4	【NORMAL】stingyなmageからのリクエスト	2025-06-14 11:44:58.056719+00	2025-06-13 15:44:58.05523+00
913d536a-51e4-4085-afb2-0a9f02f1f8cc	a2cca07e-7d98-4c4c-a188-d993b9d60759	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:44:58.05523+00	\N	\N	staff	15	87	rare	3	【NORMAL】stingyなmageからのリクエスト	2025-06-14 02:44:58.056719+00	2025-06-13 15:44:58.05523+00
4d83b78a-4a32-416b-ac93-b60447ea6b19	54ad1bf0-5097-4727-8fcc-cb72546d7e4b	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:45:04.137689+00	\N	\N	staff	26	227	common	4	【CHALLENGE】stingyなmageからのリクエスト	2025-06-13 22:45:04.138634+00	2025-06-13 15:45:04.137689+00
24a2d804-b9f2-4a80-baf2-388b0a346c0e	30a6ca1f-541c-45b0-931c-a100c30f9e09	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:46:04.007906+00	\N	\N	dagger	18	180	rare	1	【NORMAL】normalなarcherからのリクエスト	2025-06-14 12:46:04.008755+00	2025-06-13 15:46:04.007906+00
7bbd442d-da00-44c6-bad5-c74fec2ba320	59d302a9-f2bf-40f8-a8cf-f06c93c6084d	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:46:04.007906+00	\N	\N	staff	15	87	rare	1	【NORMAL】stingyなmageからのリクエスト	2025-06-13 22:46:04.008755+00	2025-06-13 15:46:04.007906+00
ab18fb23-f9db-484e-923e-ca36835e0ca3	e92cf4fd-b964-42c5-b16a-10603d9a7b0c	\N	\N	0	0	1	normal	\N	pending	2025-06-13 15:46:34.215708+00	\N	\N	staff	17	99	common	2	【NORMAL】stingyなmageからのリクエスト	2025-06-14 08:46:34.216892+00	2025-06-13 15:46:34.215708+00
\.


--
-- Data for Name: adventurer_visits; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.adventurer_visits (id, player_id, adventurer_master_id, visit_purpose, current_level, available_gold, weapon_requirements, material_offers, arrived_at, departure_time, status, interaction_data) FROM stdin;
\.


--
-- Data for Name: area_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.area_masters (id, name, description, required_shop_level, required_adventurer_level, base_expedition_time_minutes, danger_level, background_image, theme_color, is_active, display_order, created_at) FROM stdin;
forest	森林	初心者向けの平和な森林エリア	1	1	60	1	\N	#228B22	t	1	2025-06-11 22:48:29.625581+00
cave	洞窟	中級者向けの薄暗い洞窟エリア	5	10	120	3	\N	#696969	t	2	2025-06-11 22:48:29.625581+00
mountain	山岳	上級者向けの険しい山岳エリア	10	20	240	5	\N	#8B4513	t	3	2025-06-11 22:48:29.625581+00
forest_entrance	森の入り口	冒険者たちが最初に向かう平和な森	1	1	30	1	\N	\N	t	1	2025-06-12 23:52:02.645015+00
dark_woods	暗い森	少し危険な森の奥深く	2	3	60	2	\N	\N	t	2	2025-06-12 23:52:02.645015+00
mountain_cave	山の洞窟	貴重な鉱物が眠る洞窟	3	5	90	3	\N	\N	t	3	2025-06-12 23:52:02.645015+00
ancient_ruins	古代遺跡	謎に満ちた古代の建造物	4	8	120	4	\N	\N	t	4	2025-06-12 23:52:02.645015+00
dragon_lair	ドラゴンの住処	強大なドラゴンが住む危険な場所	5	10	180	5	\N	\N	t	5	2025-06-12 23:52:02.645015+00
volcano	火山エリア	高レベル向けの火山地帯	15	1	60	7	\N	\N	t	0	2025-06-13 01:02:54.907002+00
abyss	深淵エリア	最高難易度の深淵	20	1	60	10	\N	\N	t	0	2025-06-13 01:02:54.907002+00
\.


--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.attributes (id, name, emoji, color_code, description, damage_bonus, effect_description, effective_against, weak_against, is_active, created_at) FROM stdin;
fire	火	🔥	#FF4500	\N	15	火属性ダメージを追加	{ice,plant}	{water,earth}	t	2025-06-11 22:48:29.61944+00
ice	氷	❄️	#00BFFF	\N	10	氷属性ダメージを追加	{fire,earth}	{fire}	t	2025-06-11 22:48:29.61944+00
lightning	雷	⚡	#FFD700	\N	20	雷属性ダメージを追加	{water,metal}	{earth}	t	2025-06-11 22:48:29.61944+00
normal	ノーマル	🔘	#808080	通常属性	0	標準的な属性	{none}	{none}	t	2025-06-12 11:24:49.178276+00
earth	土	🌍	#8B4513	土の属性	12	土属性ダメージを追加	{water,air}	{fire,lightning}	t	2025-06-12 11:24:49.197447+00
water	水	💧	#0066CC	水の属性	12	水属性ダメージを追加	{fire,earth}	{ice,lightning}	t	2025-06-12 11:24:49.207326+00
magic	魔	✨	#9966FF	魔法属性	18	魔法ダメージを追加	{physical}	{anti-magic}	t	2025-06-12 11:24:49.222531+00
light	光	☀️	#FFD700	光の属性	15	光属性ダメージを追加	{dark}	{dark}	t	2025-06-12 11:24:49.240638+00
dark	闇	🌑	#4B0082	闇の属性	15	闇属性ダメージを追加	{light}	{light}	t	2025-06-12 11:24:49.247602+00
wind	風	💨	#87CEEB	風の属性	14	風属性ダメージを追加	{earth}	{lightning}	t	2025-06-12 11:24:49.25641+00
poison	毒	☠️	#800080	毒の属性	16	毒ダメージを追加	{organic}	{immune}	t	2025-06-12 11:24:49.263072+00
\.


--
-- Data for Name: character_conversations; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.character_conversations (id, player_id, character_id, conversation_type, conversation_text, trust_gained, created_at) FROM stdin;
\.


--
-- Data for Name: character_unlock_logs; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.character_unlock_logs (id, player_id, character_id, unlock_method, unlock_condition_met, created_at) FROM stdin;
711f74e6-5c37-414f-9b94-8304b2211828	ce0b1337-753c-45fd-ab5a-473b0d10c736	6	manual	テスト解放	2025-06-13 04:04:25.609093+00
\.


--
-- Data for Name: crafting_recipes; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.crafting_recipes (id, name, description, gold_cost, success_rate, required_level, is_active, created_at, updated_at, weapon_id) FROM stdin;
17	アルケインスタッフのレシピ	秘術の力を宿した杖を作成する神秘レシピ	750	0.85	7	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	1
25	大魔法使いの杖のレシピ	大魔法使いが使った伝説の杖を作成する究極レシピ	3200	0.7	10	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	2
30	アルテミスの弓のレシピ	狩猟の女神の神弓を作成する神域のレシピ	12000	0.5	15	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	3
12	祝福の剣のレシピ	聖なる力で祝福された剣を作成する神聖レシピ	1250	0.8	8	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	4
26	コスモススタッフのレシピ	宇宙の力を宿した最高級杖を作成する宇宙レシピ	5400	0.6	12	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	5
33	創世の杖のレシピ	世界を創造した神の杖を作成する創造のレシピ	22000	0.4	18	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	6
9	クリスタルスタッフのレシピ	クリスタルスタッフを作成する上級レシピ	210	1	3	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	7
29	デーモンベインのレシピ	悪魔を滅ぼす究極の剣を作成する審判のレシピ	20000	0.4	18	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	8
20	ドラゴンスレイヤーのレシピ	ドラゴンを倒すための究極の剣を作成する伝説レシピ	6000	0.6	12	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	9
15	エルフの弓のレシピ	エルフの技術で作る精密な弓のレシピ	1125	0.8	8	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	10
28	エクスカリバーのレシピ	選ばれし者のみが扱える聖剣を作成する運命のレシピ	15000	0.5	15	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	11
19	炎の剣のレシピ	炎の力を宿した伝説の剣を作成する危険なレシピ	4000	0.7	10	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	12
5	ハンターボウのレシピ	ハンターボウを作成する中級レシピ	160	1	2	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	13
31	インフィニティボウのレシピ	無限の力を秘めた究極の弓を作成する無限レシピ	18000	0.4	18	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	14
1	鉄の剣のレシピ	基本的な鉄の剣を作成するレシピ	100	1	1	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	15
3	騎士の剣のレシピ	騎士の剣を作成する上級レシピ	300	1	3	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	16
6	ロングボウのレシピ	ロングボウを作成する上級レシピ	240	1	3	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	17
8	魔法使いの杖のレシピ	魔法使いの杖を作成する中級レシピ	140	1	2	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	18
14	マジックボウのレシピ	魔法の矢を放つ弓を作成する特殊レシピ	800	0.85	7	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	19
11	マジックソードのレシピ	魔法の力を宿した剣を作成する特殊レシピ	900	0.85	7	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	20
32	マーリンの杖のレシピ	伝説の魔法使いマーリンの杖を作成する叡智のレシピ	10000	0.5	15	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	21
23	フェニックスボウのレシピ	不死鳥の力を宿した炎の弓を作成する神話レシピ	5700	0.6	12	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	22
24	シャドウボウのレシピ	影の力で敵を貫く暗黒の弓を作成する闇のレシピ	4800	0.65	11	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	23
13	銀の弓のレシピ	美しい銀の弓を作成する高級レシピ	450	0.9	5	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	24
16	銀の杖のレシピ	銀で装飾された高級杖を作成するレシピ	400	0.9	5	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	25
10	銀の剣のレシピ	美しい銀の剣を作成する高級レシピ	500	0.9	5	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	26
2	鋼の剣のレシピ	鋼の剣を作成する中級レシピ	200	1	2	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	27
22	嵐の弓のレシピ	嵐の力を宿した雷の弓を作成する伝説レシピ	3600	0.7	10	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	28
27	タイムスタッフのレシピ	時間を操る神秘的な杖を作成する時空レシピ	4400	0.65	11	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	29
21	ヴォイドブレードのレシピ	虚無の力を宿した漆黒の剣を作成する禁断レシピ	5000	0.65	11	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	30
18	賢者の杖のレシピ	賢者の知恵を宿した杖を作成する知識レシピ	1000	0.8	8	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	31
4	木の弓のレシピ	基本的な木の弓を作成するレシピ	80	1	1	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	32
7	木の杖のレシピ	基本的な木の杖を作成するレシピ	70	1	1	t	2025-06-13 01:16:53.966378+00	2025-06-13 01:16:53.966378+00	33
\.


--
-- Data for Name: device_sessions; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.device_sessions (id, device_id, player_id, device_name, device_model, platform, platform_version, app_version, is_active, is_trusted, last_used_at, expires_at, ip_address, user_agent, refresh_token_hash, created_at, updated_at) FROM stdin;
9ca824eb-4497-4a65-944e-36373fcc9650	bukiya_8a772bcbb3a011389b277c978e103512	119e86b2-8d18-467c-a6da-09df465a01de	iPhone 16	iPhone	iOS	\N	\N	t	t	2025-06-13 12:26:57.65811+00	\N	\N	\N	\N	2025-06-12 10:35:38.386602+00	2025-06-13 12:26:57.616156+00
\.


--
-- Data for Name: enchantment_logs; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.enchantment_logs (id, player_id, weapon_id, enchantment_type_id, before_level, after_level, result, cost, materials_used, success_rate, created_at) FROM stdin;
1	119e86b2-8d18-467c-a6da-09df465a01de	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	1	0	1	success	100	{}	0.8	2025-06-13 03:54:19.22645+00
\.


--
-- Data for Name: enchantment_materials; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.enchantment_materials (id, name, description, rarity, effect_type, success_rate_bonus, cost_multiplier, max_stack, is_active, created_at, updated_at) FROM stdin;
1	基本強化石	最も基本的な強化素材	common	attack	0.05	1	999	t	2025-06-12 10:39:37.439192+00	\N
2	防御クリスタル	防御力強化に特化した素材	uncommon	defense	0.08	1.2	500	t	2025-06-12 10:39:37.439192+00	\N
3	速度ジェム	速度強化に特化した貴重な宝石	rare	speed	0.1	1.5	200	t	2025-06-12 10:39:37.439192+00	\N
4	クリティカルシャード	クリティカル強化の欠片	epic	critical	0.12	2	100	t	2025-06-12 10:39:37.439192+00	\N
5	命中パウダー	命中率を高める魔法の粉	uncommon	accuracy	0.07	1.1	300	t	2025-06-12 10:39:37.439192+00	\N
6	耐久鉱石	武器の耐久性を高める特殊鉱石	common	durability	0.06	0.9	999	t	2025-06-12 10:39:37.439192+00	\N
7	万能強化石	全ての強化に使える万能素材	legendary	\N	0.15	0.8	50	t	2025-06-12 10:39:37.439192+00	\N
8	保護の加護	強化失敗時の破壊を防ぐ	epic	protection	0	3	10	t	2025-06-12 10:39:37.439192+00	\N
\.


--
-- Data for Name: enchantment_types; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.enchantment_types (id, name, description, effect_type, effect_value, max_level, base_success_rate, base_cost, required_materials, is_active, created_at, updated_at) FROM stdin;
1	攻撃力強化	武器の攻撃力を向上させます	attack	5	10	0.8	100	{"basic_stone": 1}	t	2025-06-12 10:39:37.439192+00	\N
2	防御力強化	武器の防御効果を向上させます	defense	3	10	0.85	80	{"defense_crystal": 1}	t	2025-06-12 10:39:37.439192+00	\N
3	速度強化	武器の攻撃速度を向上させます	speed	2	15	0.75	120	{"speed_gem": 1}	t	2025-06-12 10:39:37.439192+00	\N
4	クリティカル強化	クリティカル率を向上させます	critical	1.5	20	0.7	150	{"critical_shard": 1}	t	2025-06-12 10:39:37.439192+00	\N
5	命中強化	武器の命中率を向上させます	accuracy	2.5	12	0.8	90	{"accuracy_powder": 1}	t	2025-06-12 10:39:37.439192+00	\N
6	耐久強化	武器の耐久性を向上させます	durability	10	8	0.9	70	{"durability_ore": 1}	t	2025-06-12 10:39:37.439192+00	\N
\.


--
-- Data for Name: idle_bonus_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.idle_bonus_masters (id, name, description, multiplier, duration_seconds, icon_name, bonus_type, is_active, created_at) FROM stdin;
double_income	収益2倍ブースト	1時間の間、収益が2倍になります	2	3600	income_boost	income	t	2025-06-12 10:40:10.856149
mega_boost	メガブースト	30分間、収益が3倍になります	3	1800	mega_boost	income	t	2025-06-12 10:40:10.856175
experience_boost	経験値ブースト	2時間の間、経験値獲得量が2倍になります	2	7200	exp_boost	experience	t	2025-06-12 10:40:10.856192
crafting_boost	錬成効率ブースト	1時間の間、錬成効率が1.5倍になります	1.5	3600	crafting_boost	crafting	t	2025-06-12 10:40:10.856206
super_income	スーパー収益ブースト	15分間、収益が5倍になります	5	900	super_boost	income	t	2025-06-12 10:40:10.85622
\.


--
-- Data for Name: idle_upgrade_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.idle_upgrade_masters (id, name, description, base_cost, income_multiplier, max_level, icon_name, unlock_level, is_active, created_at) FROM stdin;
efficiency_boost	効率向上	武器製造の効率を向上させ、収益を増加させます	100	1.2	20	efficiency	1	t	2025-06-12 10:40:10.637193
automation	自動化システム	製造プロセスを自動化し、大幅な収益向上を実現します	500	1.5	15	automation	3	t	2025-06-12 10:40:10.637222
quality_control	品質管理	武器の品質を向上させ、より高い価格で販売できます	250	1.3	18	quality	2	t	2025-06-12 10:40:10.637237
speed_enhancement	製造速度向上	製造速度を向上させ、より多くの武器を生産できます	150	1.15	25	speed	1	t	2025-06-12 10:40:10.63725
material_efficiency	素材効率化	素材の使用効率を向上させ、コストを削減します	300	1.25	12	materials	4	t	2025-06-12 10:40:10.637265
advanced_tools	高級工具	高品質な工具を使用し、製造効率を大幅に向上させます	1000	2	10	tools	5	t	2025-06-12 10:40:10.637281
\.


--
-- Data for Name: material_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.material_masters (name, category, rarity_id, description, base_price, price_volatility, stack_size, emoji, color_code, is_active, created_at, updated_at, id) FROM stdin;
アダマンタイト鉱石	metal	epic	伝説的な硬度を持つ希少鉱石	2000	0.30	100	💎	#4169E1	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	1
古代石	special	epic	古代の力を宿した神秘的な石	3000	0.40	999	🗿	#8A2BE2	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	2
古代の木材	organic	rare	何百年も経た硬い木材。魔法伝導性が高い	400	0.15	100	🌳	#228B22	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	3
天使の羽	special	rare	聖なる力を宿した天使の羽	820	0.25	25	👼	#F0F8FF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	4
魔獣の牙	organic	rare	強力な魔獣の鋭い牙	450	0.20	80	🦷	#FFFACD	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	5
骨	organic	common	装飾や小さな部品に使用する動物の骨	22	0.10	200	🦴	#F5F5DC	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	6
青銅合金	metal	rare	銅と錫の合金。耐久性に優れる	250	0.15	300	🟫	#CD7F32	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	7
混沌の結晶	chaos	legendary	秩序と混沌が混ざり合った究極の結晶	12000	0.50	8	🌀	#4B0082	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	8
木炭	fuel	common	高温燃焼用の燃料。鍛冶に必須	40	0.10	300	⚫	#36454F	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	9
粘土	earth	common	陶器や鋳型作りに使える良質な粘土	8	0.10	999	🟤	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	10
石炭	fuel	common	鍛冶の燃料として使用する石炭	20	0.10	999	⚫	#2F2F2F	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	11
銅鉱石	metal	common	初級武器の材料。加工しやすい鉱石	30	0.10	999	🟫	#B87333	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	12
綿花	fiber	common	布地の原料。柔らかい繊維素材	12	0.10	300	🤍	#FFFFFF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	13
悪魔の角	special	rare	強大な魔力を秘めた悪魔の角	750	0.25	30	😈	#8B0000	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	14
運命の糸	fate	legendary	運命を紡ぐ神秘的な糸	14000	0.50	6	🧵	#9370DB	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	15
神の血	divine	legendary	神々の血液から精製された聖なる液体	15000	0.60	3	🩸	#8B0000	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	16
竜の鱗	organic	rare	強固な防御力を持つ竜の鱗。非常に希少	800	0.25	50	🐉	#8B0000	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	17
地核石	elemental	rare	大地の力を宿した重厚な石	300	0.20	250	🌍	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	18
風の核	elemental	epic	風の精霊の核となる結晶	2200	0.30	60	💨	#87CEEB	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	19
地の核	elemental	epic	地の精霊の核となる結晶	2200	0.30	60	⛰️	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	20
火の核	elemental	epic	火の精霊の核となる結晶	2200	0.30	60	🔥	#FF4500	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	21
水の核	elemental	epic	水の精霊の核となる結晶	2200	0.30	60	💧	#0000FF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	22
強化石	magic	common	エンチャントに使用する基本的な魔法石	100	0.20	999	💎	#4169E1	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	23
永遠の炎	divine	legendary	決して消えることのない神の炎	16000	0.55	4	🔥	#FF69B4	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	24
羽根	organic	common	矢羽や装飾に使用する鳥の羽根	12	0.10	300	🪶	#F5F5DC	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	25
炎の石	elemental	rare	火属性の魔力を秘めた赤い石	350	0.20	200	🔥	#FF0000	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	26
毛皮	organic	common	防寒具や装飾に使用する動物の毛皮	45	0.10	100	🟤	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	27
創世の欠片	primordial	legendary	世界創造時に残された原初の物質	10000	0.50	5	🌟	#FFD700	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	28
金鉱石	metal	epic	最高級武器の材料。純度が極めて高い	1500	0.30	999	🟨	#FFD700	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	29
麻	fiber	common	丈夫な繊維。紐や布の材料	18	0.10	400	🟫	#8B7355	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	30
氷の結晶	elemental	rare	永久に溶けない氷の結晶	380	0.20	200	🧊	#B0E0E6	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	31
無限金属	cosmic	legendary	無限の可能性を秘めた幻の金属	18000	0.60	2	♾️	#C0C0C0	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	32
鉄鉱石	metal	common	武器作成の基本素材。最も一般的な鉱石	50	0.10	999	⛏️	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	33
革	organic	common	防具や武器の柄巻きに使用する革	35	0.10	500	🟤	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	34
生命の樹液	divine	epic	世界樹から採取された神聖な樹液	2800	0.35	25	🌱	#00FF00	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	35
雷の欠片	elemental	rare	雷の力を封じ込めた結晶片	420	0.20	150	⚡	#FFD700	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	36
魔法石	magic	rare	魔法武器の核となる石。魔力を蓄積できる	500	0.20	999	🔮	#9370DB	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	37
マナエッセンス	magic	rare	純粋な魔力の結晶。エンチャントに使用	600	0.25	100	💙	#00BFFF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	38
ミスリル塊	metal	epic	軽量かつ強固な幻の金属	2500	0.35	50	✨	#E6E6FA	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	39
不死鳥の羽	organic	rare	再生能力を持つ不死鳥の美しい羽	900	0.30	20	🔥	#FF4500	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	40
研磨粉	powder	common	武器の光沢を出すための粉末	30	0.10	200	⚪	#F0F8FF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	41
樹脂	organic	common	接着剤として使用する天然の樹液	28	0.10	200	🟡	#FFD700	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	42
塩	mineral	common	保存と精製に使用する天然塩	15	0.10	500	⚪	#FFFFFF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	43
砂	earth	common	研磨や鋳造に使える細かい砂	5	0.10	999	🟨	#F4A460	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	44
銀鉱石	metal	rare	中級武器の材料。魔法抵抗に優れる	200	0.15	999	⚪	#C0C0C0	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	45
魂の結晶	spirit	epic	純粋な魂の力を封じ込めた結晶	2600	0.30	40	👻	#9370DB	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	46
精霊石	magic	rare	精霊の力を宿した宝石。属性付与に使用	700	0.20	50	💎	#FF69B4	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	47
星の欠片	cosmic	epic	天から降ってきた隕石の破片	3200	0.40	15	⭐	#FFD700	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	48
鋼鉄塊	metal	rare	高品質な鋼鉄の塊。強度が非常に高い	300	0.15	200	⚫	#4F4F4F	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	49
石材	mineral	common	基礎的な建材。研磨や加重に使用	10	0.10	999	🪨	#808080	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	50
時の砂	temporal	epic	時間の流れを操る神秘の砂	4000	0.45	20	⏳	#DDA0DD	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	51
錫鉱石	metal	common	青銅作成に必要な錫。銅と混ぜて合金を作る	25	0.10	999	⚪	#C0C0C0	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	52
真理の結晶	abstract	legendary	全ての真理を映し出す完璧な結晶	25000	0.80	1	💎	#FFFFFF	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	53
虚空の破片	void	epic	次元の裂け目から得られる謎の物質	3500	0.40	30	🌌	#191970	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	54
虚無の心臓	void	legendary	虚無そのものの核となる物質	22000	0.70	2	🖤	#000000	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	55
砥石	mineral	common	武器を研ぐための石。切れ味を向上させる	25	0.10	500	🪨	#696969	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	56
木材	organic	common	弓や杖の材料。軽量で加工しやすい	15	0.10	999	🪵	#8B4513	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	57
世界樹の心臓	divine	legendary	世界樹の中心部から取れる究極の素材	20000	0.70	1	💚	#00FF00	t	2025-06-13 01:15:21.781774+00	2025-06-13 01:15:21.781774+00	58
\.


--
-- Data for Name: material_targeting_setups; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.material_targeting_setups (id, player_id, setup_name, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mission_progress_logs; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.mission_progress_logs (id, player_id, mission_id, action_type, progress_delta, extra_data, created_at) FROM stdin;
\.


--
-- Data for Name: mission_templates; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.mission_templates (id, name, description, mission_type, target_type, target_count, target_conditions, reward_gold, reward_exp, reward_items, is_active, reset_schedule, required_level, display_order, created_at, updated_at) FROM stdin;
1	武器を1個作成	合成で武器を1個作成しよう	daily	craft_weapon	1	\N	100	50	\N	t	\N	1	1	2025-06-12 10:38:05.003352+00	2025-06-12 10:38:05.003361+00
2	武器を2個販売	冒険者に武器を2個販売しよう	daily	sell_weapon	2	\N	200	75	\N	t	\N	1	2	2025-06-12 10:38:05.003953+00	2025-06-12 10:38:05.003958+00
3	500ゴールド獲得	合計500ゴールドを獲得しよう	daily	earn_gold	500	\N	150	60	\N	t	\N	1	3	2025-06-12 10:38:05.005408+00	2025-06-12 10:38:05.005413+00
4	武器を10個作成	週間で武器を10個作成しよう	weekly	craft_weapon	10	\N	1000	500	\N	t	\N	1	1	2025-06-12 10:38:05.005706+00	2025-06-12 10:38:05.005709+00
5	武器を15個販売	週間で武器を15個販売しよう	weekly	sell_weapon	15	\N	1500	750	\N	t	\N	1	2	2025-06-12 10:38:05.005965+00	2025-06-12 10:38:05.005968+00
6	5000ゴールド獲得	週間で5000ゴールドを獲得しよう	weekly	earn_gold	5000	\N	2000	1000	\N	t	\N	1	3	2025-06-12 10:38:05.034006+00	2025-06-12 10:38:05.034019+00
7	初めての武器作成	初めて武器を作成する	achievement	craft_weapon	1	\N	500	200	\N	t	\N	1	1	2025-06-12 10:38:05.034617+00	2025-06-12 10:38:05.034623+00
8	武器作成マスター	武器を100個作成する	achievement	craft_weapon	100	\N	10000	5000	\N	t	\N	1	2	2025-06-12 10:38:05.034899+00	2025-06-12 10:38:05.034902+00
9	商売の天才	武器を500個販売する	achievement	sell_weapon	500	\N	25000	10000	\N	t	\N	5	3	2025-06-12 10:38:05.035171+00	2025-06-12 10:38:05.035175+00
10	大富豪	合計100,000ゴールドを獲得する	achievement	earn_gold	100000	\N	50000	20000	\N	t	\N	10	4	2025-06-12 10:38:05.035698+00	2025-06-12 10:38:05.035702+00
\.


--
-- Data for Name: monster_drop_tables; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.monster_drop_tables (id, monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate, required_weapon_type, bonus_rate, is_active, created_at) FROM stdin;
e2c3259d-9aea-44a0-af8a-1b28fe3d5fa9	slime_blue	material	iron_ore	1	2	0.5000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
62511103-409c-4b2e-8254-da145621e722	slime_blue	material	wood	1	1	0.3000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
1fdd4fb3-0593-4516-b406-b38f25dfc390	slime_blue	weapon	iron_sword_common	1	1	0.0100	\N	0.0000	t	2025-06-13 01:42:19.289261+00
e3e6a65f-5038-4732-8321-42f80408c3ac	slime_blue	gold	\N	10	30	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
1ecd8499-37ce-4b8f-a617-e2c61eeca19e	slime_green	material	stone	1	3	0.6000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
23e78be1-a90b-4e76-bbd0-25285b1e3bd3	slime_green	material	hemp	1	2	0.4000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
7b3c4b42-3ac2-41c0-a29e-b599bdbdc4ed	slime_green	weapon	wooden_bow_common	1	1	0.0100	\N	0.0000	t	2025-06-13 01:42:19.289261+00
6f98c440-0b64-4f5c-968e-0499688d506c	slime_green	gold	\N	15	40	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
438d58d7-aaeb-4f23-a28d-daad59a2cdfe	spider_forest	material	bone	1	2	0.7000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
3f1177bf-4dc1-426d-9cc3-4a1b749103e0	spider_forest	material	leather	1	1	0.5000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
ee75651d-e29a-4a4d-b40b-3032229a0e54	spider_forest	weapon	wooden_staff_common	1	1	0.0100	\N	0.0000	t	2025-06-13 01:42:19.289261+00
afcb6923-e4a6-4b2e-8176-e86b14279be0	spider_forest	gold	\N	20	50	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
f8286cad-601c-42e0-8904-898bfbecc646	rabbit_wild	material	fur	1	3	0.8000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
cefdaec0-250b-4c5c-aa58-cb99d44f561e	rabbit_wild	material	feather	1	2	0.6000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
33da5a22-8f64-4406-924e-221e3da44659	rabbit_wild	weapon	hunter_bow_common	1	1	0.0200	\N	0.0000	t	2025-06-13 01:42:19.289261+00
78584a8d-b3e6-4677-9465-5442657382b7	rabbit_wild	gold	\N	25	60	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
c2a91425-df13-43bc-8a49-96fa634a7f24	spirit_tree	material	ancient_wood	1	1	0.4000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
4d6e8fb8-c90d-4b68-91e0-4be495f5ffd8	spirit_tree	material	resin	1	2	0.7000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
37e42914-290f-4953-9822-1a4008302cdb	spirit_tree	weapon	mage_staff_common	1	1	0.0200	\N	0.0000	t	2025-06-13 01:42:19.289261+00
26c5b427-29a4-4c10-a440-5346e9239cb8	spirit_tree	gold	\N	30	70	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
bb96c5cf-b8ce-4713-bb35-c12c52de1887	wolf_forest	material	silver_ore	1	1	0.3000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
0f49fa7d-7840-4c40-a88e-2f9d0e0947e3	wolf_forest	material	beast_fang	1	2	0.5000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
2369c30d-8af1-4c17-84b2-88cf20bead48	wolf_forest	weapon	silver_sword_rare	1	1	0.0300	\N	0.0000	t	2025-06-13 01:42:19.289261+00
4fd13289-a4b7-445e-8f9d-3d0f62e61f9a	wolf_forest	gold	\N	80	150	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
7b46a234-ba91-4678-bd1f-4b716f12be45	bear_forest	material	dragon_scale	1	1	0.2000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
95cd76e6-8389-4814-886d-577fe0c4fe62	bear_forest	material	magic_crystal	1	1	0.4000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
836b6c21-6c7c-46f1-b3eb-feb605eb2488	bear_forest	weapon	magic_bow_rare	1	1	0.0300	\N	0.0000	t	2025-06-13 01:42:19.289261+00
8c8918ff-a40e-4fb5-8560-290a04b63925	bear_forest	gold	\N	100	200	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
a774a24e-33b1-48df-a405-ad290d394efb	treeling	material	spirit_gem	1	1	0.3000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
ea83471a-f5f7-4f27-98df-3f83dc5b37a0	treeling	material	mana_essence	1	1	0.5000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
f4d8369e-6d95-4f54-8b6f-3e17da807d14	treeling	weapon	arcane_staff_rare	1	1	0.0300	\N	0.0000	t	2025-06-13 01:42:19.289261+00
5bd2943f-49b9-4281-91d6-b3f4a761e70d	treeling	gold	\N	120	250	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
aef5ddce-6687-4210-b95a-f013bb97cb62	god_false	material	adamantite_ore	1	1	0.3000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
f51a2e32-1dbe-456e-8fb3-69adf92437c7	god_false	material	star_fragment	1	1	0.2000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
8ef86866-e50d-48e8-8a32-7721202a028c	god_false	weapon	flame_sword_epic	1	1	0.0500	\N	0.0000	t	2025-06-13 01:42:19.289261+00
0eec5cb7-da6e-4f3d-bfbc-5befe0862129	god_false	material	chaos_crystal	1	1	0.1000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
a48e721c-c2a8-4a3d-94b4-76110fd49357	god_false	weapon	excalibur_legendary	1	1	0.0200	\N	0.0000	t	2025-06-13 01:42:19.289261+00
e475fede-5865-4527-8010-4c3c4fd61e11	god_false	gold	\N	1000	3000	0.9000	\N	0.0000	t	2025-06-13 01:42:19.289261+00
\.


--
-- Data for Name: monster_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.monster_masters (id, name, hp, attack, defense, speed, attribute_id, resistances, weaknesses, immunities, level_min, level_max, base_success_rate, emoji, description, area_id, spawn_rate, is_active, is_boss, created_at, monster_type, level, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, updated_at) FROM stdin;
spider_forest	森の蜘蛛	120	18	8	110	\N	{}	\N	\N	3	3	0.7000	\N	毒を持つ小さな蜘蛛	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	3	poison	fire	dark	17,20	100	0	12	25	2025-06-13 01:02:54.907002+00
rabbit_wild	野ウサギ	100	22	5	150	\N	{}	\N	\N	4	4	0.7000	\N	可愛らしいが意外と手強い	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	4	normal	dark	light	17,20	100	0	15	30	2025-06-13 01:02:54.907002+00
spirit_tree	木の精	180	25	15	60	\N	{}	\N	\N	5	5	0.7000	\N	森を守る小さな精霊	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	5	earth	fire	water	17,20	100	0	20	40	2025-06-13 01:02:54.907002+00
mushroom_poison	森のキノコ	150	20	12	70	\N	{}	\N	\N	6	6	0.7000	\N	毒胞子を撒き散らす	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	plant	6	poison	fire	earth	18,19	100	0	18	35	2025-06-13 01:02:54.907002+00
boar_wild	野生のイノシシ	250	35	20	80	\N	{}	\N	\N	7	7	0.7000	\N	突進攻撃が得意	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	7	normal	ice	fire	18,19	100	0	25	50	2025-06-13 01:02:54.907002+00
wolf_forest	森のオオカミ	220	40	18	120	\N	{}	\N	\N	8	8	0.7000	\N	群れで行動する賢いハンター	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	8	normal	fire	ice	20,21	100	0	30	60	2025-06-13 01:02:54.907002+00
treeling	樹人の子	300	30	25	50	\N	{}	\N	\N	9	9	0.7000	\N	古い樹木が目覚めた姿	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	9	earth	fire	poison	20,21	100	0	35	70	2025-06-13 01:02:54.907002+00
troll_forest	森のトロル	400	50	30	60	\N	{}	\N	\N	10	10	0.7000	\N	森の奥深くに住む巨大なトロル	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	humanoid	10	earth	lightning	physical	20,21	100	0	45	85	2025-06-13 01:02:54.907002+00
dragon_fire	ファイアドラゴン	1000	150	60	85	\N	{}	\N	\N	35	36	0.7000	\N	炎を吐く強力なドラゴン	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	35	fire	water	ice	22,23	100	0	180	320	2025-06-13 01:02:54.907002+00
golem_mithril	ミスリルゴーレム	700	80	70	45	\N	{}	\N	\N	26	27	0.7000	\N	ミスリルでできた高級ゴーレム	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	machine	26	metal	acid	lightning	23	100	0	128	215	2025-06-13 01:02:54.907002+00
cyclops_one_eye	一つ目巨人	750	100	50	65	\N	{}	\N	\N	25	26	0.7000	\N	一つ目の巨人	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	giant	25	earth	lightning	holy	23	100	0	122	205	2025-06-13 01:02:54.907002+00
dragon_earth	アースドラゴン	850	105	55	80	\N	{}	\N	\N	27	28	0.7000	\N	大地を操るドラゴン	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	27	earth	wind	water	23	100	0	138	235	2025-06-13 01:02:54.907002+00
angel_fallen	堕天使	500	125	25	120	\N	{}	\N	\N	28	28	0.7000	\N	天から堕ちた天使	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	angel	28	dark	holy	light	23	100	0	145	250	2025-06-13 01:02:54.907002+00
behemoth_mountain	マウンテンベヒーモス	900	95	60	55	\N	{}	\N	\N	26	27	0.7000	\N	山岳地帯の巨大獣	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	26	earth	fire	ice	23	100	0	130	220	2025-06-13 01:02:54.907002+00
roc_giant	ジャイアントロック	750	110	35	130	\N	{}	\N	\N	27	28	0.7000	\N	伝説の巨大鳥	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	bird	27	wind	lightning	earth	23	100	0	132	225	2025-06-13 01:02:54.907002+00
titan_lesser	レッサータイタン	1000	120	70	40	\N	{}	\N	\N	28	28	0.7000	\N	小さなタイタン	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	titan	28	earth	lightning	holy	23	100	0	150	260	2025-06-13 01:02:54.907002+00
salamander_lava	ラバサラマンダー	450	110	40	100	\N	{}	\N	\N	28	29	0.7000	\N	溶岩に住むトカゲ	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	reptile	28	fire	water	ice	23	100	0	125	210	2025-06-13 01:02:54.907002+00
phoenix_fire	ファイアフェニックス	600	140	35	120	\N	{}	\N	\N	32	33	0.7000	\N	炎の不死鳥	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	32	fire	water	ice	23	100	0	160	280	2025-06-13 01:02:54.907002+00
elemental_fire	ファイアエレメンタル	500	120	35	90	\N	{}	\N	\N	30	31	0.7000	\N	炎の精霊	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	30	fire	water	ice	23	100	0	145	250	2025-06-13 01:02:54.907002+00
ifrit_lesser	レッサーイフリート	700	145	45	95	\N	{}	\N	\N	34	35	0.7000	\N	下級の炎の悪魔	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	34	fire	water	holy	23	100	0	175	310	2025-06-13 01:02:54.907002+00
golem_magma	マグマゴーレム	800	125	70	50	\N	{}	\N	\N	33	34	0.7000	\N	溶岩でできたゴーレム	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	33	fire	water	earth	23	100	0	170	300	2025-06-13 01:02:54.907002+00
wyrm_lava	ラバワーム	600	115	50	80	\N	{}	\N	\N	31	32	0.7000	\N	溶岩の中を泳ぐワーム	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	31	fire	water	ice	23	100	0	155	270	2025-06-13 01:02:54.907002+00
hound_hell	ヘルハウンド	400	105	30	125	\N	{}	\N	\N	29	30	0.7000	\N	地獄の犬	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	29	fire	water	holy	23	100	0	140	240	2025-06-13 01:02:54.907002+00
djinn_fire	ファイアジン	550	135	25	115	\N	{}	\N	\N	32	33	0.7000	\N	炎のジン	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	32	fire	water	earth	23	100	0	165	290	2025-06-13 01:02:54.907002+00
spider_lava	ラバスパイダー	350	125	35	105	\N	{}	\N	\N	30	31	0.7000	\N	溶岩に住む蜘蛛	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	30	fire	water	ice	23	100	0	148	255	2025-06-13 01:02:54.907002+00
chimera_fire	ファイアキメラ	750	155	45	95	\N	{}	\N	\N	35	36	0.7000	\N	炎を吐くキメラ	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	35	fire	water	ice	23	100	0	185	330	2025-06-13 01:02:54.907002+00
serpent_flame	フレイムサーペント	550	140	30	110	\N	{}	\N	\N	33	34	0.7000	\N	炎の大蛇	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	reptile	33	fire	water	ice	23	100	0	172	305	2025-06-13 01:02:54.907002+00
raven_fire	ファイアレイヴン	300	110	20	140	\N	{}	\N	\N	29	30	0.7000	\N	炎を纏ったカラス	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	bird	29	fire	water	wind	23	100	0	142	245	2025-06-13 01:02:54.907002+00
bat_inferno	インフェルノバット	280	130	25	135	\N	{}	\N	\N	31	32	0.7000	\N	地獄の炎をまとうコウモリ	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	31	fire	water	holy	23	100	0	158	275	2025-06-13 01:02:54.907002+00
scorpion_lava	ラバスコーピオン	450	145	55	90	\N	{}	\N	\N	34	35	0.7000	\N	溶岩のサソリ	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	34	fire	water	ice	23	100	0	178	315	2025-06-13 01:02:54.907002+00
demon_fire	ファイアデーモン	650	160	40	110	\N	{}	\N	\N	36	37	0.7000	\N	炎を操る中級悪魔	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	36	fire	holy	ice	24	100	0	190	340	2025-06-13 01:02:54.907002+00
giant_fire	ファイアジャイアント	1100	140	80	60	\N	{}	\N	\N	37	38	0.7000	\N	炎の巨人	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	giant	37	fire	water	ice	24	100	0	200	360	2025-06-13 01:02:54.907002+00
balrog_young	ヤングバルログ	900	170	55	100	\N	{}	\N	\N	38	38	0.7000	\N	若いバルログ	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	38	fire	water	holy	24	100	0	220	400	2025-06-13 01:02:54.907002+00
titan_fire	ファイアタイタン	1200	160	90	55	\N	{}	\N	\N	37	38	0.7000	\N	炎のタイタン	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	titan	37	fire	water	earth	24	100	0	205	370	2025-06-13 01:02:54.907002+00
ancient_fire	エンシェントファイア	800	180	60	85	\N	{}	\N	\N	38	38	0.7000	\N	古代の炎の精霊	volcano	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	38	fire	water	holy	24	100	0	225	410	2025-06-13 01:02:54.907002+00
shadow_lord	シャドウロード	1200	200	70	120	\N	{}	\N	\N	40	42	0.7000	\N	闇の領主	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	40	dark	holy	light	24	100	0	280	500	2025-06-13 01:02:54.907002+00
void_dragon	ヴォイドドラゴン	1500	220	80	100	\N	{}	\N	\N	45	47	0.7000	\N	虚無のドラゴン	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	45	void	holy	light	24	100	0	350	650	2025-06-13 01:02:54.907002+00
slime_blue	青い粘液	50	8	2	80	\N	{}	\N	\N	1	1	0.7000	\N	初心者向けの弱いモンスター	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	normal	1	water	lightning	physical	17,18	100	0	5	10	2025-06-13 01:02:54.907002+00
slime_green	緑の粘液	80	12	3	90	\N	{}	\N	\N	2	2	0.7000	\N	少し強くなった粘液	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	normal	2	earth	fire	poison	17,18	100	0	8	15	2025-06-13 01:02:54.907002+00
mushroom_king	キノコ王	280	35	20	50	\N	{}	\N	\N	9	10	0.7000	\N	森のキノコたちの王	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	plant	9	poison	fire	light	19,20	100	0	42	80	2025-06-13 01:02:54.907002+00
ent_young	若い樹人	450	40	35	40	\N	{}	\N	\N	10	10	0.7000	\N	成長途中の樹人	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	10	earth	fire	ice	19,20	100	0	50	90	2025-06-13 01:02:54.907002+00
rat_cave	洞窟ネズミ	150	35	12	110	\N	{}	\N	\N	8	9	0.7000	\N	洞窟に住む大きなネズミ	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	8	dark	light	poison	19,20	100	0	28	50	2025-06-13 01:02:54.907002+00
golem_stone	石ゴーレム	300	25	40	60	\N	{}	\N	\N	10	11	0.7000	\N	石でできた小さなゴーレム	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	10	earth	water	physical	19,20	100	0	40	70	2025-06-13 01:02:54.907002+00
spider_cave	洞窟グモ	220	45	15	120	\N	{}	\N	\N	12	13	0.7000	\N	巨大な洞窟蜘蛛	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	12	poison	fire	light	19,20	100	0	45	80	2025-06-13 01:02:54.907002+00
bat_swarm	コウモリ群	180	55	8	150	\N	{}	\N	\N	11	12	0.7000	\N	大量のコウモリ	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	flying	11	dark	light	wind	19,20	100	0	42	75	2025-06-13 01:02:54.907002+00
mole_giant	巨大モグラ	200	30	25	80	\N	{}	\N	\N	9	10	0.7000	\N	地中を素早く移動する	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	9	earth	light	water	19,20	100	0	35	60	2025-06-13 01:02:54.907002+00
ghost_miner	鉱夫の霊	180	40	5	90	\N	{}	\N	\N	12	13	0.7000	\N	事故で亡くなった鉱夫の霊	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	ghost	12	undead	holy	physical	19,20	100	0	48	80	2025-06-13 01:02:54.907002+00
golem_copper	銅ゴーレム	320	35	35	65	\N	{}	\N	\N	11	12	0.7000	\N	銅でできたゴーレム	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	11	earth	acid	lightning	19,20	100	0	42	75	2025-06-13 01:02:54.907002+00
slime_metal	メタルスライム	100	20	50	200	\N	{}	\N	\N	10	11	0.7000	\N	非常に硬く逃げ足が速い	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	rare	10	metal	acid	physical	19,20	100	0	100	200	2025-06-13 01:02:54.907002+00
lizard_ore	鉱石トカゲ	380	48	30	90	\N	{}	\N	\N	14	15	0.7000	\N	鉱石のように硬い鱗	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	14	earth	ice	lightning	21	100	0	55	95	2025-06-13 01:02:54.907002+00
orc_cave	洞窟オーク	450	65	25	80	\N	{}	\N	\N	15	16	0.7000	\N	武器を持った凶暴なオーク	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	humanoid	15	dark	light	holy	21	100	0	65	110	2025-06-13 01:02:54.907002+00
snake_pit	地底蛇	380	70	18	100	\N	{}	\N	\N	16	17	0.7000	\N	毒牙を持つ巨大な地底蛇	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	16	poison	ice	fire	21	100	0	70	120	2025-06-13 01:02:54.907002+00
golem_iron	鉄ゴーレム	550	55	45	50	\N	{}	\N	\N	17	18	0.7000	\N	鉄でできた強固なゴーレム	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	machine	17	earth	lightning	fire	21	100	0	75	130	2025-06-13 01:02:54.907002+00
crystal_spider	水晶蜘蛛	250	50	20	105	\N	{}	\N	\N	13	14	0.7000	\N	水晶の体を持つ美しい蜘蛛	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	13	crystal	physical	dark	21	100	0	50	85	2025-06-13 01:02:54.907002+00
salamander_fire	ファイアサラマンダー	280	60	20	110	\N	{}	\N	\N	14	15	0.7000	\N	炎を吐く両生類	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	reptile	14	fire	water	ice	21	100	0	58	100	2025-06-13 01:02:54.907002+00
skeleton_warrior	スケルトン戦士	300	55	15	95	\N	{}	\N	\N	15	16	0.7000	\N	武器を持った骸骨戦士	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	undead	15	undead	holy	physical	21	100	0	62	105	2025-06-13 01:02:54.907002+00
worm_rock	ロックワーム	420	45	35	70	\N	{}	\N	\N	16	17	0.7000	\N	岩を食べる巨大なミミズ	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	16	earth	fire	acid	21	100	0	68	115	2025-06-13 01:02:54.907002+00
gargoyle_stone	ストーンガーゴイル	480	50	40	60	\N	{}	\N	\N	17	18	0.7000	\N	石の翼を持つ悪魔	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	17	earth	holy	dark	21	100	0	72	125	2025-06-13 01:02:54.907002+00
crystal_golem	クリスタルゴーレム	400	40	45	55	\N	{}	\N	\N	16	17	0.7000	\N	美しい水晶でできたゴーレム	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	16	crystal	physical	dark	21	100	0	70	120	2025-06-13 01:02:54.907002+00
cave_troll	洞窟トロル	700	70	35	60	\N	{}	\N	\N	17	18	0.7000	\N	洞窟に住む大型トロル	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	humanoid	17	earth	fire	holy	21	100	0	78	135	2025-06-13 01:02:54.907002+00
phantom_bat	ファントムバット	200	65	10	140	\N	{}	\N	\N	14	15	0.7000	\N	幽霊のようなコウモリ	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	undead	14	dark	light	holy	21	100	0	56	95	2025-06-13 01:02:54.907002+00
earth_elemental	アースエレメンタル	500	45	50	50	\N	{}	\N	\N	15	16	0.7000	\N	大地の力を宿した精霊	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	15	earth	wind	water	21	100	0	65	110	2025-06-13 01:02:54.907002+00
orc_king	洞窟王オーク	650	80	40	70	\N	{}	\N	\N	18	18	0.7000	\N	オーク族の王	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	boss	18	dark	light	holy	22	100	0	85	150	2025-06-13 01:02:54.907002+00
minotaur_young	若いミノタウロス	600	75	30	85	\N	{}	\N	\N	18	18	0.7000	\N	牛頭の獣人	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	18	earth	lightning	holy	22	100	0	80	140	2025-06-13 01:02:54.907002+00
cave_dragon	洞窟ドラゴン	800	90	45	80	\N	{}	\N	\N	18	18	0.7000	\N	洞窟に住む小さなドラゴン	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	18	earth	ice	holy	22	100	0	90	160	2025-06-13 01:02:54.907002+00
eagle_giant	巨大ワシ	320	75	20	140	\N	{}	\N	\N	18	19	0.7000	\N	山の頂上に住む巨大なワシ	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	bird	18	wind	lightning	earth	22	100	0	75	130	2025-06-13 01:02:54.907002+00
goat_mountain	山ヤギ	280	65	25	120	\N	{}	\N	\N	19	20	0.7000	\N	険しい山を駆け回るヤギ	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	19	earth	fire	water	22	100	0	70	125	2025-06-13 01:02:54.907002+00
giant_snow	雪男	600	80	35	70	\N	{}	\N	\N	20	21	0.7000	\N	雪山に住む巨大な雪男	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	humanoid	20	ice	fire	lightning	22	100	0	85	150	2025-06-13 01:02:54.907002+00
griffin_young	若いグリフィン	450	90	30	110	\N	{}	\N	\N	22	23	0.7000	\N	ワシとライオンの合体獣	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	22	wind	earth	dark	22	100	0	95	170	2025-06-13 01:02:54.907002+00
yeti_alpha	アルファイエティ	700	95	40	85	\N	{}	\N	\N	24	25	0.7000	\N	イエティたちのリーダー	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	24	ice	fire	lightning	22	100	0	110	185	2025-06-13 01:02:54.907002+00
harpy_mountain	マウンテンハーピー	380	85	25	125	\N	{}	\N	\N	21	22	0.7000	\N	美しい声で誘惑する鳥女	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	21	wind	lightning	holy	22	100	0	90	160	2025-06-13 01:02:54.907002+00
bee_giant	巨大ミツバチ	90	25	5	140	\N	{}	\N	\N	3	4	0.7000	\N	大きな針を持つミツバチ	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	insect	3	wind	fire	poison	17	100	0	14	28	2025-06-13 01:02:54.907002+00
pixie_mischief	いたずら妖精	80	30	8	160	\N	{}	\N	\N	4	5	0.7000	\N	魔法を使ういたずら好きな妖精	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	fairy	4	light	dark	earth	17	100	0	16	32	2025-06-13 01:02:54.907002+00
snake_grass	草ヘビ	130	28	10	100	\N	{}	\N	\N	5	6	0.7000	\N	草に紛れる毒蛇	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	5	poison	ice	fire	18	100	0	22	42	2025-06-13 01:02:54.907002+00
owl_great	大フクロウ	180	35	12	130	\N	{}	\N	\N	7	8	0.7000	\N	夜行性の大型フクロウ	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	bird	7	wind	lightning	dark	18	100	0	28	55	2025-06-13 01:02:54.907002+00
stag_giant	巨大シカ	200	32	15	90	\N	{}	\N	\N	6	7	0.7000	\N	立派な角を持つ巨大なシカ	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	6	earth	fire	water	18	100	0	24	48	2025-06-13 01:02:54.907002+00
sprite_water	水の精霊	120	22	18	80	\N	{}	\N	\N	5	6	0.7000	\N	森の泉に住む水精霊	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	5	water	lightning	fire	18	100	0	20	40	2025-06-13 01:02:54.907002+00
badger_giant	巨大アナグマ	240	38	22	85	\N	{}	\N	\N	7	8	0.7000	\N	穴掘りが得意な大型アナグマ	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	7	earth	lightning	water	18	100	0	32	60	2025-06-13 01:02:54.907002+00
bear_forest	森グマ	350	45	25	70	\N	{}	\N	\N	8	9	0.7000	\N	森の主とも呼ばれる大型熊	forest	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	8	normal	fire	ice	19,20	100	0	38	75	2025-06-13 01:02:54.907002+00
dwarf_zombie	ドワーフゾンビ	280	48	20	75	\N	{}	\N	\N	13	14	0.7000	\N	ゾンビ化したドワーフ	cave	0.1000	t	f	2025-06-13 01:02:54.907002+00	undead	13	undead	holy	fire	21	100	0	52	90	2025-06-13 01:02:54.907002+00
troll_frost	フロストトロル	650	85	45	75	\N	{}	\N	\N	23	24	0.7000	\N	氷の力を操るトロル	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	humanoid	23	ice	fire	holy	22	100	0	105	180	2025-06-13 01:02:54.907002+00
wolf_dire	ダイアウルフ	350	70	22	130	\N	{}	\N	\N	19	20	0.7000	\N	巨大な狼の祖先	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	19	ice	fire	holy	22	100	0	78	135	2025-06-13 01:02:54.907002+00
bear_cave	ケイブベア	550	75	35	80	\N	{}	\N	\N	20	21	0.7000	\N	洞窟に住む巨大な熊	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	20	earth	fire	ice	22	100	0	82	145	2025-06-13 01:02:54.907002+00
giant_stone	ストーンジャイアント	800	70	60	50	\N	{}	\N	\N	24	25	0.7000	\N	石でできた巨人	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	giant	24	earth	wind	lightning	22	100	0	115	190	2025-06-13 01:02:54.907002+00
elemental_ice	アイスエレメンタル	400	65	45	70	\N	{}	\N	\N	22	23	0.7000	\N	氷の精霊	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	elemental	22	ice	fire	physical	22	100	0	98	165	2025-06-13 01:02:54.907002+00
giant_spider	ジャイアントスパイダー	380	80	25	110	\N	{}	\N	\N	21	22	0.7000	\N	山に住む巨大蜘蛛	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	21	poison	fire	ice	22	100	0	88	155	2025-06-13 01:02:54.907002+00
sphinx_riddle	リドルスフィンクス	600	85	40	90	\N	{}	\N	\N	24	25	0.7000	\N	謎かけを出すスフィンクス	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	24	wind	dark	physical	22	100	0	112	185	2025-06-13 01:02:54.907002+00
dragon_ice	アイスドラゴン	800	100	50	90	\N	{}	\N	\N	25	26	0.7000	\N	氷の息を吐く中型ドラゴン	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	25	ice	fire	physical	23	100	0	120	200	2025-06-13 01:02:54.907002+00
mammoth_ice	アイスマンモス	900	90	55	60	\N	{}	\N	\N	26	27	0.7000	\N	氷河期の巨大マンモス	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	26	ice	fire	lightning	23	100	0	125	210	2025-06-13 01:02:54.907002+00
phoenix_dark	ダークフェニックス	600	110	35	100	\N	{}	\N	\N	28	28	0.7000	\N	闇に堕ちた不死鳥	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	28	dark	holy	water	23	100	0	140	240	2025-06-13 01:02:54.907002+00
wyvern_frost	フロストワイバーン	650	95	40	105	\N	{}	\N	\N	25	26	0.7000	\N	氷の翼を持つワイバーン	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	25	ice	fire	earth	23	100	0	118	195	2025-06-13 01:02:54.907002+00
lich_mountain	マウンテンリッチ	550	120	30	60	\N	{}	\N	\N	27	28	0.7000	\N	山頂の古城に住むリッチ	mountain	0.1000	t	f	2025-06-13 01:02:54.907002+00	undead	27	undead	holy	fire	23	100	0	135	230	2025-06-13 01:02:54.907002+00
demon_arch	アーチデーモン	1300	210	75	110	\N	{}	\N	\N	42	44	0.7000	\N	上級悪魔	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	demon	42	dark	holy	fire	24	100	0	320	580	2025-06-13 01:02:54.907002+00
lich_ancient	エンシェントリッチ	1000	240	60	80	\N	{}	\N	\N	44	46	0.7000	\N	古代のリッチ	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	undead	44	undead	holy	fire	24	100	0	340	620	2025-06-13 01:02:54.907002+00
titan_void	ヴォイドタイタン	1800	190	100	60	\N	{}	\N	\N	46	48	0.7000	\N	虚無のタイタン	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	titan	46	void	holy	light	24	100	0	380	700	2025-06-13 01:02:54.907002+00
seraph_fallen	堕天熾天使	1100	260	50	130	\N	{}	\N	\N	48	50	0.7000	\N	堕ちた最高位の天使	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	angel	48	dark	holy	light	24	100	0	420	800	2025-06-13 01:02:54.907002+00
hydra_chaos	カオスヒドラ	1400	180	85	90	\N	{}	\N	\N	43	45	0.7000	\N	混沌の多頭竜	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	dragon	43	chaos	holy	order	24	100	0	360	660	2025-06-13 01:02:54.907002+00
kraken_abyss	アビスクラーケン	1600	170	90	70	\N	{}	\N	\N	41	43	0.7000	\N	深淵の大タコ	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	beast	41	water	lightning	fire	24	100	0	300	540	2025-06-13 01:02:54.907002+00
phoenix_void	ヴォイドフェニックス	900	250	40	140	\N	{}	\N	\N	47	49	0.7000	\N	虚無の不死鳥	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	mythical	47	void	holy	life	24	100	0	400	750	2025-06-13 01:02:54.907002+00
god_false	偽りの神	2000	300	120	80	\N	{}	\N	\N	50	50	0.7000	\N	神を騙る存在	abyss	0.1000	t	f	2025-06-13 01:02:54.907002+00	god	50	divine	void	chaos	24	100	0	500	1000	2025-06-13 01:02:54.907002+00
\.


--
-- Data for Name: player_adventurer_relationships; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_adventurer_relationships (player_id, adventurer_master_id, trust_level, total_trades, successful_expeditions, failed_expeditions, total_gold_traded, best_deal_margin, first_met_at, last_interaction_at) FROM stdin;
\.


--
-- Data for Name: player_character_bonds; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_character_bonds (id, player_id, character_id, trust_level, friendship_level, total_trust_points, total_interactions, total_weapon_gifts, total_quests_together, total_dragon_battles, current_level, current_experience, is_unlocked, is_favorited, equipped_weapon_id, custom_nickname, conversation_flags, story_progress, special_events, unlock_date, last_interaction_at, last_level_up_at, created_at, updated_at) FROM stdin;
4b83254a-4c25-40f7-9c9b-6af20d98ff73	119e86b2-8d18-467c-a6da-09df465a01de	6	50	1	0	0	0	0	0	1	0	t	f	\N	\N	{}	{}	[]	2025-06-13 03:14:53.754243+00	\N	\N	2025-06-13 03:14:53.754243+00	2025-06-13 03:14:53.754243+00
4829558c-b0e6-451c-b2f5-170e820729f6	ce0b1337-753c-45fd-ab5a-473b0d10c736	6	0	1	0	0	0	0	0	1	0	t	f	\N	\N	{}	{}	[]	2025-06-13 04:04:25.606867+00	\N	\N	2025-06-13 04:04:25.612763+00	2025-06-13 04:04:25.612765+00
\.


--
-- Data for Name: player_enchantment_materials; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_enchantment_materials (id, player_id, material_id, quantity, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: player_idle_bonuses; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_idle_bonuses (id, player_id, idle_system_id, bonus_id, start_time, created_at) FROM stdin;
\.


--
-- Data for Name: player_idle_systems; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_idle_systems (id, player_id, base_income_per_second, current_level, upgrade_count, multiplier, last_collected_at, experience, created_at, updated_at) FROM stdin;
1	119e86b2-8d18-467c-a6da-09df465a01de	21	21	0	1	2025-06-13 15:16:24.24755	1303	2025-06-13 00:21:22.187618	2025-06-13 15:16:24.278224
\.


--
-- Data for Name: player_idle_upgrades; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_idle_upgrades (id, player_id, idle_system_id, upgrade_id, level, created_at, updated_at) FROM stdin;
1	119e86b2-8d18-467c-a6da-09df465a01de	1	efficiency_boost	0	2025-06-13 00:21:22.208104	2025-06-13 00:21:22.208106
2	119e86b2-8d18-467c-a6da-09df465a01de	1	speed_enhancement	0	2025-06-13 00:21:22.208109	2025-06-13 00:21:22.20811
\.


--
-- Data for Name: player_materials; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_materials (player_id, quantity, total_acquired, total_used, last_acquired_at, material_id, created_at, updated_at, material_master_id) FROM stdin;
119e86b2-8d18-467c-a6da-09df465a01de	1	0	0	\N	\N	2025-06-13 13:37:26.847749+00	2025-06-13 13:37:26.847749+00	3
119e86b2-8d18-467c-a6da-09df465a01de	2	0	0	\N	\N	2025-06-13 13:27:23.452421+00	2025-06-13 13:37:26.847749+00	6
119e86b2-8d18-467c-a6da-09df465a01de	1	0	0	\N	\N	2025-06-13 13:37:26.847749+00	2025-06-13 13:37:26.847749+00	17
119e86b2-8d18-467c-a6da-09df465a01de	3	0	0	\N	\N	2025-06-13 13:10:58.161193+00	2025-06-13 13:10:58.161193+00	30
119e86b2-8d18-467c-a6da-09df465a01de	27	0	0	\N	\N	2025-06-13 13:10:58.161193+00	2025-06-13 14:52:17.299278+00	33
119e86b2-8d18-467c-a6da-09df465a01de	1	0	0	\N	\N	2025-06-13 13:27:45.675259+00	2025-06-13 13:27:45.675259+00	34
119e86b2-8d18-467c-a6da-09df465a01de	1	0	0	\N	\N	2025-06-13 13:27:23.452421+00	2025-06-13 13:27:23.452421+00	42
119e86b2-8d18-467c-a6da-09df465a01de	8	0	0	\N	\N	2025-06-13 13:10:58.161193+00	2025-06-13 13:27:23.452421+00	50
119e86b2-8d18-467c-a6da-09df465a01de	1	0	0	\N	\N	2025-06-13 13:10:58.161193+00	2025-06-13 13:10:58.161193+00	57
\.


--
-- Data for Name: player_missions; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_missions (id, player_id, mission_template_id, current_progress, is_completed, is_claimed, created_at, completed_at, claimed_at, expires_at) FROM stdin;
0b199c22-36a4-416b-8fd1-b49382c47d25	119e86b2-8d18-467c-a6da-09df465a01de	4	0	f	f	2025-06-12 23:52:17.881619+00	\N	\N	2025-06-16 00:00:00+00
bbe61568-23bc-4a45-9fd8-eee049f5e796	119e86b2-8d18-467c-a6da-09df465a01de	5	0	f	f	2025-06-12 23:52:17.881619+00	\N	\N	2025-06-16 00:00:00+00
ab67e585-f7a2-4f35-9fed-85495d1393ed	119e86b2-8d18-467c-a6da-09df465a01de	6	0	f	f	2025-06-12 23:52:17.881619+00	\N	\N	2025-06-16 00:00:00+00
f67ed8cb-6444-439d-8409-aa1fc60fa0df	119e86b2-8d18-467c-a6da-09df465a01de	1	0	f	f	2025-06-13 00:12:43.14739+00	\N	\N	2025-06-14 00:00:00+00
96d7f5aa-ffe2-430f-b2ec-ad160ab2e0c2	119e86b2-8d18-467c-a6da-09df465a01de	2	0	f	f	2025-06-13 00:12:43.14739+00	\N	\N	2025-06-14 00:00:00+00
0de7dae2-cb53-4014-917e-af813d5051da	119e86b2-8d18-467c-a6da-09df465a01de	3	0	f	f	2025-06-13 00:12:43.14739+00	\N	\N	2025-06-14 00:00:00+00
abcffce7-e1f0-42a0-abbd-395ca7aedad4	119e86b2-8d18-467c-a6da-09df465a01de	1	0	f	f	2025-06-12 23:52:17.877418+00	\N	\N	2025-06-13 00:00:00+00
44059019-8c0b-4f67-a369-80666cb8e0b3	119e86b2-8d18-467c-a6da-09df465a01de	2	0	f	f	2025-06-12 23:52:17.877418+00	\N	\N	2025-06-13 00:00:00+00
3f8ba183-e0f4-4b92-b159-015a5a102d73	119e86b2-8d18-467c-a6da-09df465a01de	3	0	f	f	2025-06-12 23:52:17.877418+00	\N	\N	2025-06-13 00:00:00+00
\.


--
-- Data for Name: player_statistics; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_statistics (player_id, total_play_time_seconds, session_count, last_session_duration, total_gold_earned, total_gold_spent, total_gems_purchased, total_gems_spent, weapons_crafted, enchants_attempted, enchants_succeeded, trades_completed, expeditions_sent, highest_weapon_attack, highest_enchant_level, max_daily_gold, updated_at) FROM stdin;
550e8400-e29b-41d4-a716-446655440000	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	2025-06-11 22:48:29.962685+00
119e86b2-8d18-467c-a6da-09df465a01de	0	0	0	224643	0	0	0	0	0	0	0	0	0	0	0	2025-06-13 15:46:28.828799+00
ce0b1337-753c-45fd-ab5a-473b0d10c736	0	0	0	380	0	0	0	0	0	0	0	0	0	0	0	2025-06-13 08:16:45.186145+00
\.


--
-- Data for Name: player_weapons; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.player_weapons (id, player_id, base_attack, enchant_level, current_durability, max_durability, abilities, custom_name, is_favorite, acquired_at, last_used_at, is_equipped, is_locked, attack, created_at, updated_at, weapon_master_id) FROM stdin;
f41b6862-a855-4060-a943-4a33f6be3841	119e86b2-8d18-467c-a6da-09df465a01de	20	0	100	100	[]	\N	f	2025-06-13 06:15:54.865094+00	\N	f	f	20	2025-06-13 06:15:54.865094+00	2025-06-13 06:15:54.865094+00	35
407a40f0-4a74-4669-82b5-37851a9c9229	119e86b2-8d18-467c-a6da-09df465a01de	33	0	100	100	[]	\N	f	2025-06-13 06:15:43.071827+00	\N	f	f	33	2025-06-13 06:15:43.071827+00	2025-06-13 06:15:43.071827+00	36
b7dbf1c3-fdd9-4cb8-8686-246058386036	119e86b2-8d18-467c-a6da-09df465a01de	23	0	100	100	[]	\N	f	2025-06-13 06:15:51.762299+00	\N	f	f	23	2025-06-13 06:15:51.762299+00	2025-06-13 06:15:51.762299+00	37
21799ee9-dcbf-435a-ba16-b399b00c3483	119e86b2-8d18-467c-a6da-09df465a01de	30	0	100	100	[]	\N	f	2025-06-13 06:15:45.693117+00	\N	f	f	30	2025-06-13 06:15:45.693117+00	2025-06-13 06:15:45.693117+00	38
c5054965-b1eb-4068-a018-aeb43acea901	119e86b2-8d18-467c-a6da-09df465a01de	125	0	100	100	[]	\N	f	2025-06-13 15:46:27.458506+00	\N	f	f	125	2025-06-13 15:46:27.458506+00	2025-06-13 15:46:27.458506+00	16
59c8de5b-551e-4a75-b44a-b9f4d0f626ab	119e86b2-8d18-467c-a6da-09df465a01de	125	0	100	100	[]	\N	f	2025-06-13 15:46:28.179895+00	\N	f	f	125	2025-06-13 15:46:28.179895+00	2025-06-13 15:46:28.179895+00	16
c5fab079-cfa2-427a-84f4-f2d0bd89283d	119e86b2-8d18-467c-a6da-09df465a01de	125	0	100	100	[]	\N	f	2025-06-13 15:46:28.828799+00	\N	f	f	125	2025-06-13 15:46:28.828799+00	2025-06-13 15:46:28.828799+00	16
0faf26d9-aab4-4642-8e7e-54fb26a690c5	119e86b2-8d18-467c-a6da-09df465a01de	65	0	100	100	[]	\N	f	2025-06-13 01:22:58.03733+00	\N	f	f	65	2025-06-13 01:22:58.03733+00	2025-06-13 01:22:58.03733+00	15
bc6fb7c5-8dd9-400c-b53e-56771f9e0fd2	119e86b2-8d18-467c-a6da-09df465a01de	65	0	100	100	[]	\N	f	2025-06-13 01:24:37.499837+00	\N	f	f	65	2025-06-13 01:24:37.499837+00	2025-06-13 01:24:37.499837+00	15
b0183b57-215b-4b53-a189-76cd951d4675	119e86b2-8d18-467c-a6da-09df465a01de	65	0	100	100	[]	\N	f	2025-06-13 05:45:52.36899+00	\N	f	f	65	2025-06-13 05:45:52.36899+00	2025-06-13 05:45:52.36899+00	15
7aa4f203-fc18-4cef-8263-6ad6acde1b02	ce0b1337-753c-45fd-ab5a-473b0d10c736	65	0	100	100	[]	\N	f	2025-06-13 08:14:10.856419+00	\N	f	f	65	2025-06-13 08:14:10.856419+00	2025-06-13 08:14:10.856419+00	15
29915dce-385e-47b7-a457-1488b98f0e80	119e86b2-8d18-467c-a6da-09df465a01de	85	0	100	100	[]	\N	f	2025-06-13 05:45:47.190544+00	\N	f	f	85	2025-06-13 05:45:47.190544+00	2025-06-13 05:45:47.190544+00	18
4db8757f-ef96-42be-95c3-0f0f535d8970	119e86b2-8d18-467c-a6da-09df465a01de	100	0	100	100	[]	\N	f	2025-06-13 05:45:50.13454+00	\N	f	f	100	2025-06-13 05:45:50.13454+00	2025-06-13 05:45:50.13454+00	27
da067690-db60-4cc1-9dff-1b8e50daff0e	119e86b2-8d18-467c-a6da-09df465a01de	60	0	100	100	[]	\N	f	2025-06-13 01:22:06.702275+00	\N	f	f	60	2025-06-13 01:22:06.702275+00	2025-06-13 01:22:06.702275+00	32
e80e3186-3d83-40f8-854b-bff0298ffb48	119e86b2-8d18-467c-a6da-09df465a01de	60	0	100	100	[]	\N	f	2025-06-13 01:22:21.664436+00	\N	f	f	60	2025-06-13 01:22:21.664436+00	2025-06-13 01:22:21.664436+00	32
8df07f99-80ad-4d5a-839a-618f70701684	119e86b2-8d18-467c-a6da-09df465a01de	60	0	100	100	[]	\N	f	2025-06-13 01:24:03.203346+00	\N	f	f	60	2025-06-13 01:24:03.203346+00	2025-06-13 01:24:03.203346+00	32
b5f54503-2ae4-478b-9ccd-f2d6b27cc540	119e86b2-8d18-467c-a6da-09df465a01de	60	0	100	100	[]	\N	f	2025-06-13 02:21:10.1551+00	\N	f	f	60	2025-06-13 02:21:10.1551+00	2025-06-13 02:21:10.1551+00	32
bdf5aec9-db03-42c1-8d7d-18a6a5fba45f	119e86b2-8d18-467c-a6da-09df465a01de	55	0	100	100	[]	\N	f	2025-06-13 01:24:33.944715+00	\N	f	f	55	2025-06-13 01:24:33.944715+00	2025-06-13 01:24:33.944715+00	33
e83549ad-27c5-4fbe-8a95-2bec8a3f7726	119e86b2-8d18-467c-a6da-09df465a01de	55	0	100	100	[]	\N	f	2025-06-13 05:44:29.163369+00	\N	f	f	55	2025-06-13 05:44:29.163369+00	2025-06-13 05:44:29.163369+00	33
6668a6cc-653c-4e4c-ade4-b9fd953eb6d4	119e86b2-8d18-467c-a6da-09df465a01de	25	0	100	100	[]	\N	f	2025-06-13 06:15:47.786611+00	\N	f	f	25	2025-06-13 06:15:47.786611+00	2025-06-13 06:15:47.786611+00	34
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.players (id, username, email, password_hash, gold, gems, shop_level, reputation, created_at, updated_at, last_login, is_active, is_banned, ban_reason, shop_exp, idle_income_rate, idle_income_multiplier, last_idle_collection_time, last_visitor_spawn_time, banned_at, ban_expires_at) FROM stdin;
550e8400-e29b-41d4-a716-446655440000	admin_test	admin@bukiya.local	$2b$12$LQv3c1yqBwEFxDcTxOQxqOeDAOGNcqxvA/j2d1Xa.6adc4a4Gqbuy	10000	500	5	50	2025-06-11 22:48:29.953177+00	2025-06-11 22:48:29.953177+00	2025-06-11 22:48:29.953177+00	t	f	\N	0	10	100	2025-06-12 10:23:18.31399+00	\N	\N	\N
119e86b2-8d18-467c-a6da-09df465a01de	Guest_8e103512	testuser@example.com	$2b$12$/nwTD1SspGLE7Z0VgKZg4.ySQZHa630SUj9p3Yi70P/YMc/6tHgh.	220799	0	4	1	2025-06-12 10:35:38.386602+00	2025-06-13 15:46:28.874133+00	2025-06-13 13:50:27.116707+00	t	f	\N	164	10	100	2025-06-12 10:35:38.386602+00	2025-06-13 12:29:55.047056+00	\N	\N
ce0b1337-753c-45fd-ab5a-473b0d10c736	testuser	test@example.com	$2b$12$RzCKHCqq27E8rI6f86gSfeCMS0f3fU6hWSV7nfiDR0s6ZL56xJJBO	990	0	1	1	2025-06-13 03:30:53.889847+00	2025-06-13 12:47:33.624014+00	2025-06-13 12:47:33.93931+00	t	f	\N	50	10	100	2025-06-13 03:30:53.889847+00	2025-06-13 08:16:30.955296+00	\N	\N
\.


--
-- Data for Name: quest_area_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.quest_area_masters (id, name, area_type, difficulty, required_level, duration_minutes, image_url, background_color, description, unlock_condition, is_active, display_order, created_at, updated_at) FROM stdin;
17	近くの森	forest	1	1	30	\N	#4CAF50	初心者向けの平和な森	\N	t	0	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
18	洞窟の入口	cave	2	5	45	\N	#795548	薄暗い洞窟の入口付近	\N	t	1	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
19	古い遺跡	ruins	3	10	60	\N	#9E9E9E	古代文明の遺跡	\N	t	2	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
20	深い森	forest	3	8	75	\N	#2E7D32	森の奥深く、危険な獣が住む	\N	t	3	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
21	地下洞窟	cave	4	15	90	\N	#424242	地下深くの危険な洞窟	\N	t	4	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
22	魔法の森	magical_forest	4	20	120	\N	#673AB7	魔法に満ちた不思議な森	\N	t	5	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
23	竜の巣窟	dragon_lair	5	30	150	\N	#D32F2F	伝説の竜が住むと言われる洞窟	\N	t	6	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
24	天空の遺跡	sky_ruins	5	35	180	\N	#03A9F4	雲の上に浮かぶ古代遺跡	\N	t	7	2025-06-13 00:17:54.437995+00	2025-06-13 00:17:54.437995+00
\.


--
-- Data for Name: quest_rewards; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.quest_rewards (id, adventurer_quest_id, item_type, item_id, quantity, buyback_price, buyback_deadline, is_bought, created_at) FROM stdin;
26753713-683d-4e6d-989b-8607ed313a5b	1ae264d9-b86a-43a5-83ec-25a755640387	gold	None	26	50	2025-06-14 08:57:24.496933+00	f	2025-06-13 08:57:24.420423+00
aa651734-4ef9-48a4-bfef-f73e280043e7	1ae264d9-b86a-43a5-83ec-25a755640387	material	fur	2	90	2025-06-14 08:57:24.496933+00	f	2025-06-13 08:57:24.420423+00
54e3c072-302c-48ad-8365-22a5abc64c67	1ae264d9-b86a-43a5-83ec-25a755640387	gold	None	34	50	2025-06-14 08:57:24.496933+00	f	2025-06-13 08:57:24.420423+00
0d53fa7f-7c27-45c3-941a-8665b3dcb290	318dacbc-1438-4cd5-81d2-f4b319bc596f	gold	gold	130	130	2025-06-14 09:33:49.568209+00	f	2025-06-13 09:33:49.558575+00
49bf41f7-164e-4b64-b106-6533a21b5d4f	318dacbc-1438-4cd5-81d2-f4b319bc596f	material	1	3	50	2025-06-14 09:33:49.568209+00	f	2025-06-13 09:33:49.558575+00
f6daa424-7b13-4480-9d7e-678617f573aa	6fb3c717-e08e-41f8-9486-cf3f290e0357	material	1	1	20	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:15.056475+00
fd87e4aa-d544-4123-a17e-ac4e5c154624	cd364b6e-387e-42fd-8483-e8339d179c5b	material	hemp	2	18	2025-06-14 09:04:11.040303+00	t	2025-06-13 09:04:11.005259+00
fe0d036b-ed54-4218-a4c9-36a49ff41827	a5702bce-0a8a-4286-acb2-32cd55a1cd1d	material	wood	1	15	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.711588+00
1b41d56f-984a-40a2-b2aa-5b640aea6f32	76d3a379-3656-44a2-8115-1a1941b421b3	material	1	1	20	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.824158+00
5588c688-4031-4088-8ae3-5b6aa096579d	9040306c-588a-4e0e-9c22-733af6ccf27b	material	1	1	20	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.810807+00
891fceae-2886-4fe0-acd4-57d47175f28b	bbd22738-1de1-42b5-9cb5-c42bb6d49d70	material	1	1	20	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.743793+00
ac378b08-b405-4c87-9f77-a5d5020c6cf0	38b3a05e-c463-4e30-abe5-3d77db831c07	material	1	1	20	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.628389+00
ebc6c67c-6e50-4ea8-a039-f108cb63b27a	ce52ca92-abf7-4c3f-b686-e236850fdace	material	1	1	20	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.891278+00
0e99f807-6ae7-4744-b3bc-b74c7b0c2851	eafeee04-b121-4d3e-994c-a92427c38af1	material	bone	1	22	2025-06-14 08:58:17.288522+00	t	2025-06-13 08:58:17.36292+00
00316ad5-2fca-4a31-9b91-d3a2a275f9eb	1e6d7958-bf2e-494f-b101-1bb97d2aa561	material	hemp	1	18	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.792182+00
235e93db-12f3-4281-a7c2-af5f3de7751d	647f5876-aa8d-4b47-8b45-d864b27d4e29	material	stone	2	10	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.541487+00
349ad790-0455-45cf-ba20-0d723faa159b	5711d13c-cbf2-4789-93e5-c052c0525444	material	1	1	20	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.585394+00
56eb96ef-2487-4e9d-96ca-d62b7c608346	a1ccb729-9ecc-4677-9d97-5a79d67411b1	material	stone	1	10	2025-06-14 09:03:11.140941+00	t	2025-06-13 09:03:11.101164+00
7dd4cc46-1ea1-4ebe-ac9a-002d8d3e93b0	be6c8f5a-34af-4aa8-a135-e446f3150196	material	1	1	20	2025-06-14 09:04:41.139848+00	t	2025-06-13 09:04:41.11837+00
b249367d-5a9a-488a-b247-31494d28b8e0	f314502e-c689-4c3e-95fd-186901b7aecf	material	1	1	20	2025-06-14 09:03:41.26487+00	t	2025-06-13 09:03:41.242753+00
b2e8f0d0-9653-403e-ae3c-41c286402614	cd364b6e-387e-42fd-8483-e8339d179c5b	material	stone	3	10	2025-06-14 09:04:11.040303+00	t	2025-06-13 09:04:11.005259+00
eaa2d03f-e984-47c7-adb9-de773b8057de	b9e08a70-35f3-4cff-9f5d-ece9cffdb8ed	material	1	1	20	2025-06-14 09:11:11.081306+00	t	2025-06-13 09:11:11.069914+00
7bcb0565-a080-462d-8ebe-abdd6db654d7	1e6d7958-bf2e-494f-b101-1bb97d2aa561	material	stone	2	30	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.792182+00
f474b19c-9b6d-4283-a7f1-7da5dd5c0953	c15c28f2-4932-4b3c-bb90-8751b83ded0d	material	resin	1	28	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.972797+00
285d87bd-1a90-44e7-a8c4-aea77059ec0a	a6a27118-b623-443e-a4a4-525edfb97a8d	material	leather	1	35	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.688932+00
0a074f13-c718-4708-ae73-f7c79f9cf090	a5702bce-0a8a-4286-acb2-32cd55a1cd1d	material	iron_ore	2	100	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.711588+00
19507e82-43bd-4cf0-963d-70b5eb64542a	16a8823a-b52a-4f1f-a978-ea16353f9152	material	bone	1	44	2025-06-14 09:01:41.145479+00	t	2025-06-13 09:01:41.124492+00
24d0ca43-6171-45cc-9eb2-780197496612	47748578-579a-4b1e-a079-4ee4aa1379b1	gold	gold	60	60	2025-06-14 13:09:45.320471+00	t	2025-06-13 13:09:45.304807+00
34e46e7c-8f70-4ea6-b0dd-e11efd0016cb	a9a2a054-67dc-4ccb-84f5-8299dd0a0db3	gold	gold	200	200	2025-06-14 12:57:45.338376+00	t	2025-06-13 12:57:45.304703+00
3640c040-26c0-479d-aa03-57df313386e3	492984d3-597b-472e-80a6-447c7dd7b733	gold	None	32	50	2025-06-14 08:58:17.288522+00	t	2025-06-13 08:58:17.244505+00
38eb9a46-0c31-4079-ab9c-6825b89d1b35	b9ceadbe-2a42-4a84-be7f-a254f3ba85e8	gold	None	18	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.669222+00
4626ddf1-910b-47ac-a78b-40178d2fa753	a5702bce-0a8a-4286-acb2-32cd55a1cd1d	gold	None	27	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.711588+00
499d5798-a63b-4598-8d13-02b43ede6589	47748578-579a-4b1e-a079-4ee4aa1379b1	material	1	2	50	2025-06-14 13:09:45.320471+00	t	2025-06-13 13:09:45.304807+00
4e303499-f4ec-4cc3-a70c-9c014a10692f	a1ccb729-9ecc-4677-9d97-5a79d67411b1	material	iron_ore	2	50	2025-06-14 09:03:11.140941+00	t	2025-06-13 09:03:11.101164+00
532023c4-d06f-4eae-9c5c-a827cd88bc87	647f5876-aa8d-4b47-8b45-d864b27d4e29	gold	None	24	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.541487+00
564652c8-3072-4f9a-89c0-f8209b7287a4	16a8823a-b52a-4f1f-a978-ea16353f9152	gold	None	21	50	2025-06-14 09:01:41.145479+00	t	2025-06-13 09:01:41.124492+00
5f1bc0e1-cd29-4123-9460-ff242cfaa529	a9a2a054-67dc-4ccb-84f5-8299dd0a0db3	material	1	2	50	2025-06-14 12:57:45.338376+00	t	2025-06-13 12:57:45.304703+00
63b51b81-2321-4ccd-b8c1-4e30934a27a6	d2f693ba-cc52-42e3-a65a-c1e2fa2f6efe	material	iron_ore	2	100	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.482426+00
6606e055-b70a-465c-8e02-a643857afff2	390313b7-38a0-4614-b929-6689607df383	material	iron_ore	2	100	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.833797+00
6a7a719d-281a-4eb5-ae2b-f376ff8e091a	88c1436c-a08e-4485-be44-757c3575e21e	gold	None	143	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.767652+00
6b3ef585-f8f1-47bc-90df-5b6f4838ff03	88c1436c-a08e-4485-be44-757c3575e21e	material	dragon_scale	1	800	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.767652+00
6bebb036-9959-4a1b-8f4f-8cb84e58cd0a	b749852b-2a84-4f88-b19d-d912215bb81d	gold	gold	66	66	2025-06-14 13:24:47.38673+00	t	2025-06-13 13:24:47.353588+00
b387c7b5-1f7f-412a-baef-ff62cc57ff20	390313b7-38a0-4614-b929-6689607df383	gold	None	17	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.833797+00
ca72bc4b-32be-40a1-97a0-b21bea6432c8	b9ceadbe-2a42-4a84-be7f-a254f3ba85e8	material	iron_ore	1	100	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.669222+00
d49fe517-a6ba-42e4-b804-f37a8c05f337	a1ccb729-9ecc-4677-9d97-5a79d67411b1	gold	None	11	50	2025-06-14 09:03:11.140941+00	t	2025-06-13 09:03:11.101164+00
d5bfed1a-6472-4b7c-9898-7a6b6eef9ef2	b749852b-2a84-4f88-b19d-d912215bb81d	material	1	1	50	2025-06-14 13:24:47.38673+00	t	2025-06-13 13:24:47.353588+00
dce10358-360e-4751-9fb8-aa5afa8c7125	a1ccb729-9ecc-4677-9d97-5a79d67411b1	gold	None	39	50	2025-06-14 09:03:11.140941+00	t	2025-06-13 09:03:11.101164+00
e316132e-012a-4c3c-9ffb-d492fa3fde10	c15c28f2-4932-4b3c-bb90-8751b83ded0d	material	ancient_wood	1	400	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.972797+00
eae203cf-e9e5-4631-857b-fdb78ce8eb08	cd364b6e-387e-42fd-8483-e8339d179c5b	gold	None	21	50	2025-06-14 09:04:11.040303+00	t	2025-06-13 09:04:11.005259+00
ecb035e9-a20f-4d8f-9627-20ac6d1332b9	d2f693ba-cc52-42e3-a65a-c1e2fa2f6efe	gold	None	15	50	2025-06-14 12:27:14.561453+00	t	2025-06-13 12:27:14.482426+00
f8210a18-8048-486d-94f8-717a2d9ff463	a6a27118-b623-443e-a4a4-525edfb97a8d	gold	None	49	50	2025-06-14 08:57:24.496933+00	t	2025-06-13 08:57:24.688932+00
4903da87-25fd-4ed7-baa4-f6be0b6082b4	11ae9b72-a595-45dc-967f-fe86ac2893d0	gold	gold	40	40	2025-06-14 13:48:26.410211+00	t	2025-06-13 13:48:26.337039+00
d1706920-72e9-4c65-993d-7828dd9b2271	11ae9b72-a595-45dc-967f-fe86ac2893d0	material	1	3	50	2025-06-14 13:48:26.410211+00	t	2025-06-13 13:48:26.337039+00
\.


--
-- Data for Name: rarity_levels; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.rarity_levels (id, name, level, color_code, star_display, attack_multiplier, max_enchant_level, ability_slots, base_drop_rate, price_multiplier, is_active, created_at, updated_at) FROM stdin;
common	Common	1	#9E9E9E	★	1.00	10	0	0.6000	1.00	t	2025-06-13 01:12:27.577783+00	2025-06-13 01:12:27.577783+00
rare	Rare	2	#2196F3	★★	1.20	10	0	0.6000	1.50	t	2025-06-13 01:12:27.577783+00	2025-06-13 01:12:27.577783+00
epic	Epic	3	#9C27B0	★★★	1.50	10	0	0.6000	2.00	t	2025-06-13 01:12:27.577783+00	2025-06-13 01:12:27.577783+00
legendary	Legendary	4	#FF9800	★★★★	2.00	10	0	0.6000	3.00	t	2025-06-13 01:12:27.577783+00	2025-06-13 01:12:27.577783+00
\.


--
-- Data for Name: recipe_materials; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.recipe_materials (recipe_id, quantity, material_id) FROM stdin;
19	3	1
20	5	1
21	4	1
20	3	2
27	5	2
5	2	3
6	4	3
8	2	3
9	3	3
13	3	3
14	2	3
15	5	3
16	2	3
17	2	3
18	4	3
22	8	3
23	6	3
24	7	3
12	2	4
18	2	4
20	8	5
5	2	6
2	2	7
29	3	8
31	2	8
1	2	11
2	4	11
21	6	14
24	8	14
30	3	15
32	5	15
28	2	16
29	3	16
33	5	16
19	5	17
20	10	17
22	2	19
26	2	19
19	2	21
23	3	21
26	2	21
3	1	23
6	1	23
8	2	23
10	3	23
11	5	23
12	8	23
13	3	23
14	5	23
15	8	23
16	3	23
17	5	23
18	8	23
28	3	24
33	4	24
4	10	25
5	15	25
19	8	26
23	12	26
28	1	28
32	2	28
33	3	28
4	3	30
5	5	30
6	8	30
29	1	32
31	2	32
1	5	33
2	8	33
3	2	34
30	5	35
14	2	36
22	10	36
8	1	37
9	2	37
10	1	37
16	3	37
9	1	38
11	3	38
14	4	38
17	5	38
25	15	38
25	2	39
26	3	39
27	2	39
13	5	40
15	3	40
22	8	40
23	15	40
7	1	42
10	5	45
11	3	45
12	4	45
13	4	45
16	3	45
21	3	46
24	2	46
11	2	47
12	3	47
15	2	47
17	3	47
18	4	47
25	10	47
25	3	48
26	5	48
30	8	48
32	10	48
3	3	49
10	2	49
7	2	50
27	8	51
31	15	51
28	1	53
32	1	53
21	5	54
24	4	54
27	3	54
29	2	55
31	1	55
1	1	57
4	5	57
7	4	57
30	1	58
33	1	58
\.


--
-- Data for Name: season_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.season_masters (id, name, description, start_date, end_date, display_order, is_active, created_at, updated_at) FROM stdin;
1	シーズン1	最初のシーズン。基本的な武器が含まれます。	2024-01-01	\N	1	t	2025-06-13 06:06:08.874555+00	2025-06-13 06:06:08.874555+00
2	シーズン2	第二のシーズン。より強力な武器が追加されます。	2024-06-01	\N	2	t	2025-06-13 06:06:08.874555+00	2025-06-13 06:06:08.874555+00
3	限定イベント	イベント限定武器のシーズン	2024-12-01	\N	3	f	2025-06-13 06:06:08.874555+00	2025-06-13 06:06:08.874555+00
4	更新されたテストシーズン	APIテスト用のシーズン	2025-01-01	2025-06-30	4	f	2025-06-13 06:13:47.271441+00	2025-06-13 06:17:56.075619+00
\.


--
-- Data for Name: targeting_material_weights; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.targeting_material_weights (id, setup_id, material_id, weight, priority, created_at) FROM stdin;
\.


--
-- Data for Name: trade_logs; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.trade_logs (id, player_id, trade_type, counterpart_type, counterpart_id, gold_amount, gems_amount, items_given, items_received, success, notes, created_at) FROM stdin;
\.


--
-- Data for Name: weapon_enchantments; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.weapon_enchantments (id, weapon_id, enchantment_type_id, level, success_count, failure_count, total_cost, created_at, updated_at) FROM stdin;
1	b5f54503-2ae4-478b-9ccd-f2d6b27cc540	1	1	1	0	100	2025-06-13 03:54:19.22645+00	\N
\.


--
-- Data for Name: weapon_master_abilities; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.weapon_master_abilities (weapon_master_id, ability_id, slot_number, probability) FROM stdin;
\.


--
-- Data for Name: weapon_masters; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.weapon_masters (name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description, is_active, created_at, updated_at, season_id, id) FROM stdin;
ハンターボウ	bow	common	75	110	360	540	10	2	狩人が使う実用的な弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	13
鉄の剣	sword	common	50	80	200	300	5	1	基本的な鉄製の剣。初心者におすすめ	t	2025-06-13 01:13:52.512035+00	2025-06-13 06:22:15.237704+00	1	15
騎士の剣	sword	common	100	150	600	900	15	3	騎士が愛用する実用的な剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 06:22:34.472133+00	2	16
ロングボウ	bow	common	90	135	540	810	15	3	長距離射撃に適した弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	17
魔法使いの杖	staff	common	70	100	320	480	10	2	魔法使いが愛用する杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	18
マジックソード	sword	rare	180	280	1800	2700	45	7	魔法の力を宿した神秘的な剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	20
銀の剣	sword	rare	120	200	1000	1500	30	5	銀で作られた美しい剣。高い魔法抵抗を持つ	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	26
鋼の剣	sword	common	80	120	400	600	10	2	鋼で作られた丈夫な剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 06:22:34.400536+00	1	27
木の弓	bow	common	45	75	180	270	5	1	木製の基本的な弓。軽量で扱いやすい	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	32
木の杖	staff	common	40	70	160	240	5	1	木製の基本的な杖。魔法の入門用	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	33
訓練用の弓	bow	common	20	30	40	70	3	1	初心者用の訓練用弓。軽量で扱いやすい	t	2025-06-13 05:50:24.472222+00	2025-06-13 05:50:24.472222+00	\N	34
訓練用の短剣	dagger	common	15	25	30	60	3	1	初心者用の訓練用短剣。軽くて素早い攻撃が可能	t	2025-06-13 05:50:24.472222+00	2025-06-13 05:50:24.472222+00	\N	35
訓練用のハンマー	hammer	common	28	38	55	85	3	1	初心者用の訓練用ハンマー。重いが威力がある	t	2025-06-13 05:50:24.472222+00	2025-06-13 05:50:24.472222+00	\N	36
訓練用の杖	staff	common	18	28	35	65	3	1	初心者用の訓練用杖。魔法の練習に最適	t	2025-06-13 05:50:24.472222+00	2025-06-13 05:50:24.472222+00	\N	37
訓練用の剣	sword	common	25	35	50	80	3	1	初心者用の訓練用剣。攻撃力は低いが扱いやすい	t	2025-06-13 05:50:24.472222+00	2025-06-13 05:50:24.472222+00	\N	38
祝福の剣	sword	rare	220	320	2500	3750	60	8	聖なる力で祝福された聖剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	4
クリスタルスタッフ	staff	common	85	125	480	720	15	3	水晶を埋め込んだ美しい杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	7
大魔法使いの杖	staff	epic	300	400	6400	9600	120	10	大魔法使いが使った伝説の杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	2
アルテミスの弓	bow	legendary	480	650	18000	27000	240	15	狩猟の女神が愛用した神弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	3
コスモススタッフ	staff	epic	360	480	10800	16200	180	12	宇宙の力を宿した最高級の杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	5
創世の杖	staff	legendary	500	680	20000	30000	300	18	世界を創造した神の杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	6
デーモンベイン	sword	legendary	550	750	25000	37500	300	18	悪魔を滅ぼすために作られた究極の剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	8
ドラゴンスレイヤー	sword	epic	400	550	12000	18000	180	12	ドラゴンを倒すために作られた伝説の大剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	9
エルフの弓	bow	rare	200	290	2250	3375	60	8	エルフの技術で作られた精密な弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	10
エクスカリバー	sword	legendary	500	700	20000	30000	240	15	選ばれし者のみが扱える聖なる剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	11
炎の剣	sword	epic	350	450	8000	12000	120	10	炎の力を宿した伝説の剣。火属性攻撃付与	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	12
インフィニティボウ	bow	legendary	520	700	22000	33000	300	18	無限の力を秘めた究極の弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	14
マジックボウ	bow	rare	160	250	1600	2400	45	7	魔法の矢を放つ特殊な弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	19
マーリンの杖	staff	legendary	450	600	16000	24000	240	15	伝説の魔法使いマーリンの杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	21
フェニックスボウ	bow	epic	380	500	11400	17100	180	12	不死鳥の力を宿した炎の弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	22
シャドウボウ	bow	epic	360	480	9600	14400	150	11	影の力で敵を貫く暗黒の弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	23
銀の弓	bow	rare	110	180	900	1350	30	5	銀で装飾された美しい弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	24
銀の杖	staff	rare	100	160	800	1200	30	5	銀で装飾された高級な杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	25
嵐の弓	bow	epic	320	420	7200	10800	120	10	嵐の力を宿した雷属性の弓	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	28
タイムスタッフ	staff	epic	340	460	8800	13200	150	11	時間を操る神秘的な杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	29
ヴォイドブレード	sword	epic	380	500	10000	15000	150	11	虚無の力を宿した漆黒の剣	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	30
賢者の杖	staff	rare	180	270	2000	3000	60	8	賢者が愛用した知恵の杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	31
アルケインスタッフ	staff	rare	150	230	1500	2250	45	7	秘術の力を宿した神秘的な杖	t	2025-06-13 01:13:52.512035+00	2025-06-13 01:13:52.512035+00	\N	1
\.


--
-- Data for Name: weapon_types; Type: TABLE DATA; Schema: public; Owner: bukiya_user
--

COPY public.weapon_types (id, name, emoji, description, base_multiplier, attack_speed_modifier, critical_rate_bonus, special_effect, is_active, display_order, created_at, updated_at) FROM stdin;
sword	剣	\N	近接武器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:24.916562+00	\N
staff	杖	\N	魔法武器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:24.916562+00	\N
bow	弓	\N	遠距離武器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:24.916562+00	\N
axe	斧	\N	重武器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:24.916562+00	\N
dagger	短剣	\N	軽武器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:24.916562+00	\N
hammer	ハンマー	\N	重厚な攻撃力を持つ鈍器	1.00	1.00	0	\N	t	0	2025-06-13 00:41:34.566976+00	\N
\.


--
-- Name: adventurer_characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.adventurer_characters_id_seq', 20, true);


--
-- Name: crafting_recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.crafting_recipes_id_seq', 33, true);


--
-- Name: enchantment_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.enchantment_logs_id_seq', 1, true);


--
-- Name: enchantment_materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.enchantment_materials_id_seq', 8, true);


--
-- Name: enchantment_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.enchantment_types_id_seq', 6, true);


--
-- Name: mission_progress_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.mission_progress_logs_id_seq', 1, false);


--
-- Name: mission_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.mission_templates_id_seq', 10, true);


--
-- Name: player_enchantment_materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.player_enchantment_materials_id_seq', 1, false);


--
-- Name: player_idle_bonuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.player_idle_bonuses_id_seq', 1, false);


--
-- Name: player_idle_systems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.player_idle_systems_id_seq', 1, true);


--
-- Name: player_idle_upgrades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.player_idle_upgrades_id_seq', 2, true);


--
-- Name: quest_area_masters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.quest_area_masters_id_seq', 24, true);


--
-- Name: season_masters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.season_masters_id_seq', 4, true);


--
-- Name: weapon_enchantments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bukiya_user
--

SELECT pg_catalog.setval('public.weapon_enchantments_id_seq', 1, true);


--
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- Name: active_processes active_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.active_processes
    ADD CONSTRAINT active_processes_pkey PRIMARY KEY (id);


--
-- Name: admin_logs admin_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_pkey PRIMARY KEY (id);


--
-- Name: adventurer_characters adventurer_characters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_characters
    ADD CONSTRAINT adventurer_characters_pkey PRIMARY KEY (id);


--
-- Name: adventurer_instances adventurer_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_instances
    ADD CONSTRAINT adventurer_instances_pkey PRIMARY KEY (id);


--
-- Name: adventurer_masters adventurer_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_masters
    ADD CONSTRAINT adventurer_masters_pkey PRIMARY KEY (id);


--
-- Name: adventurer_purchases adventurer_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_purchases
    ADD CONSTRAINT adventurer_purchases_pkey PRIMARY KEY (id);


--
-- Name: adventurer_quests adventurer_quests_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_quests
    ADD CONSTRAINT adventurer_quests_pkey PRIMARY KEY (id);


--
-- Name: adventurer_requests adventurer_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_requests
    ADD CONSTRAINT adventurer_requests_pkey PRIMARY KEY (id);


--
-- Name: adventurer_visits adventurer_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_visits
    ADD CONSTRAINT adventurer_visits_pkey PRIMARY KEY (id);


--
-- Name: area_masters area_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.area_masters
    ADD CONSTRAINT area_masters_pkey PRIMARY KEY (id);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: character_conversations character_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_conversations
    ADD CONSTRAINT character_conversations_pkey PRIMARY KEY (id);


--
-- Name: character_unlock_logs character_unlock_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_unlock_logs
    ADD CONSTRAINT character_unlock_logs_pkey PRIMARY KEY (id);


--
-- Name: crafting_recipes crafting_recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.crafting_recipes
    ADD CONSTRAINT crafting_recipes_pkey PRIMARY KEY (id);


--
-- Name: device_sessions device_sessions_device_id_key; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.device_sessions
    ADD CONSTRAINT device_sessions_device_id_key UNIQUE (device_id);


--
-- Name: device_sessions device_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.device_sessions
    ADD CONSTRAINT device_sessions_pkey PRIMARY KEY (id);


--
-- Name: enchantment_logs enchantment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_logs
    ADD CONSTRAINT enchantment_logs_pkey PRIMARY KEY (id);


--
-- Name: enchantment_materials enchantment_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_materials
    ADD CONSTRAINT enchantment_materials_pkey PRIMARY KEY (id);


--
-- Name: enchantment_types enchantment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_types
    ADD CONSTRAINT enchantment_types_pkey PRIMARY KEY (id);


--
-- Name: idle_bonus_masters idle_bonus_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.idle_bonus_masters
    ADD CONSTRAINT idle_bonus_masters_pkey PRIMARY KEY (id);


--
-- Name: idle_upgrade_masters idle_upgrade_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.idle_upgrade_masters
    ADD CONSTRAINT idle_upgrade_masters_pkey PRIMARY KEY (id);


--
-- Name: material_masters material_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.material_masters
    ADD CONSTRAINT material_masters_pkey PRIMARY KEY (id);


--
-- Name: material_targeting_setups material_targeting_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.material_targeting_setups
    ADD CONSTRAINT material_targeting_setups_pkey PRIMARY KEY (id);


--
-- Name: mission_progress_logs mission_progress_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_progress_logs
    ADD CONSTRAINT mission_progress_logs_pkey PRIMARY KEY (id);


--
-- Name: mission_templates mission_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_templates
    ADD CONSTRAINT mission_templates_pkey PRIMARY KEY (id);


--
-- Name: monster_drop_tables monster_drop_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.monster_drop_tables
    ADD CONSTRAINT monster_drop_tables_pkey PRIMARY KEY (id);


--
-- Name: monster_masters monster_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.monster_masters
    ADD CONSTRAINT monster_masters_pkey PRIMARY KEY (id);


--
-- Name: player_adventurer_relationships player_adventurer_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_adventurer_relationships
    ADD CONSTRAINT player_adventurer_relationships_pkey PRIMARY KEY (player_id, adventurer_master_id);


--
-- Name: player_character_bonds player_character_bonds_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_character_bonds
    ADD CONSTRAINT player_character_bonds_pkey PRIMARY KEY (id);


--
-- Name: player_enchantment_materials player_enchantment_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_enchantment_materials
    ADD CONSTRAINT player_enchantment_materials_pkey PRIMARY KEY (id);


--
-- Name: player_idle_bonuses player_idle_bonuses_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_bonuses
    ADD CONSTRAINT player_idle_bonuses_pkey PRIMARY KEY (id);


--
-- Name: player_idle_systems player_idle_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_systems
    ADD CONSTRAINT player_idle_systems_pkey PRIMARY KEY (id);


--
-- Name: player_idle_systems player_idle_systems_player_id_key; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_systems
    ADD CONSTRAINT player_idle_systems_player_id_key UNIQUE (player_id);


--
-- Name: player_idle_upgrades player_idle_upgrades_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_upgrades
    ADD CONSTRAINT player_idle_upgrades_pkey PRIMARY KEY (id);


--
-- Name: player_missions player_missions_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_missions
    ADD CONSTRAINT player_missions_pkey PRIMARY KEY (id);


--
-- Name: player_statistics player_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_statistics
    ADD CONSTRAINT player_statistics_pkey PRIMARY KEY (player_id);


--
-- Name: player_weapons player_weapons_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_weapons
    ADD CONSTRAINT player_weapons_pkey PRIMARY KEY (id);


--
-- Name: players players_email_key; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_email_key UNIQUE (email);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_username_key; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_username_key UNIQUE (username);


--
-- Name: quest_area_masters quest_area_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.quest_area_masters
    ADD CONSTRAINT quest_area_masters_pkey PRIMARY KEY (id);


--
-- Name: quest_rewards quest_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.quest_rewards
    ADD CONSTRAINT quest_rewards_pkey PRIMARY KEY (id);


--
-- Name: rarity_levels rarity_levels_new_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.rarity_levels
    ADD CONSTRAINT rarity_levels_new_pkey PRIMARY KEY (id);


--
-- Name: season_masters season_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.season_masters
    ADD CONSTRAINT season_masters_pkey PRIMARY KEY (id);


--
-- Name: targeting_material_weights targeting_material_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.targeting_material_weights
    ADD CONSTRAINT targeting_material_weights_pkey PRIMARY KEY (id);


--
-- Name: trade_logs trade_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.trade_logs
    ADD CONSTRAINT trade_logs_pkey PRIMARY KEY (id);


--
-- Name: weapon_enchantments weapon_enchantments_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_enchantments
    ADD CONSTRAINT weapon_enchantments_pkey PRIMARY KEY (id);


--
-- Name: weapon_master_abilities weapon_master_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_master_abilities
    ADD CONSTRAINT weapon_master_abilities_pkey PRIMARY KEY (weapon_master_id, ability_id, slot_number);


--
-- Name: weapon_master_abilities weapon_master_abilities_weapon_master_id_slot_number_key; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_master_abilities
    ADD CONSTRAINT weapon_master_abilities_weapon_master_id_slot_number_key UNIQUE (weapon_master_id, slot_number);


--
-- Name: weapon_masters weapon_masters_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_masters
    ADD CONSTRAINT weapon_masters_pkey PRIMARY KEY (id);


--
-- Name: weapon_types weapon_types_pkey; Type: CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_types
    ADD CONSTRAINT weapon_types_pkey PRIMARY KEY (id);


--
-- Name: idx_active_processes_completion; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_completion ON public.active_processes USING btree (completed_at) WHERE (completed_at IS NOT NULL);


--
-- Name: idx_active_processes_data; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_data ON public.active_processes USING gin (process_data);


--
-- Name: idx_active_processes_player; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_player ON public.active_processes USING btree (player_id);


--
-- Name: idx_active_processes_result; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_result ON public.active_processes USING gin (result_data);


--
-- Name: idx_active_processes_status; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_status ON public.active_processes USING btree (status);


--
-- Name: idx_active_processes_type; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_active_processes_type ON public.active_processes USING btree (process_type);


--
-- Name: idx_admin_logs_admin; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_admin_logs_admin ON public.admin_logs USING btree (admin_user);


--
-- Name: idx_admin_logs_created; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_admin_logs_created ON public.admin_logs USING btree (created_at);


--
-- Name: idx_adventurer_visits_departure; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_adventurer_visits_departure ON public.adventurer_visits USING btree (departure_time);


--
-- Name: idx_adventurer_visits_player; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_adventurer_visits_player ON public.adventurer_visits USING btree (player_id);


--
-- Name: idx_adventurer_visits_status; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_adventurer_visits_status ON public.adventurer_visits USING btree (status);


--
-- Name: idx_monster_drops_monster; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_monster_drops_monster ON public.monster_drop_tables USING btree (monster_master_id);


--
-- Name: idx_monster_drops_type; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_monster_drops_type ON public.monster_drop_tables USING btree (drop_type, drop_target_id);


--
-- Name: idx_monster_masters_active; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_monster_masters_active ON public.monster_masters USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_monster_masters_area; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_monster_masters_area ON public.monster_masters USING btree (area_id);


--
-- Name: idx_player_materials_player_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_player_materials_player_id ON public.player_materials USING btree (player_id);


--
-- Name: idx_player_materials_quantity; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_player_materials_quantity ON public.player_materials USING btree (quantity) WHERE (quantity > 0);


--
-- Name: idx_player_weapons_abilities; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_player_weapons_abilities ON public.player_weapons USING gin (abilities);


--
-- Name: idx_player_weapons_equipped; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_player_weapons_equipped ON public.player_weapons USING btree (player_id, is_equipped) WHERE (is_equipped = true);


--
-- Name: idx_player_weapons_player_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_player_weapons_player_id ON public.player_weapons USING btree (player_id);


--
-- Name: idx_players_active; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_players_active ON public.players USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_players_email; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_players_email ON public.players USING btree (email);


--
-- Name: idx_players_last_login; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_players_last_login ON public.players USING btree (last_login);


--
-- Name: idx_players_username; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_players_username ON public.players USING btree (username);


--
-- Name: idx_season_masters_display_order; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_season_masters_display_order ON public.season_masters USING btree (display_order);


--
-- Name: idx_season_masters_is_active; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_season_masters_is_active ON public.season_masters USING btree (is_active);


--
-- Name: idx_season_masters_name; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_season_masters_name ON public.season_masters USING btree (name);


--
-- Name: idx_trade_logs_created; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_trade_logs_created ON public.trade_logs USING btree (created_at);


--
-- Name: idx_trade_logs_player; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_trade_logs_player ON public.trade_logs USING btree (player_id);


--
-- Name: idx_weapon_masters_season_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX idx_weapon_masters_season_id ON public.weapon_masters USING btree (season_id);


--
-- Name: ix_adventurer_characters_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_id ON public.adventurer_characters USING btree (id);


--
-- Name: ix_adventurer_characters_is_active; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_is_active ON public.adventurer_characters USING btree (is_active);


--
-- Name: ix_adventurer_characters_name; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_name ON public.adventurer_characters USING btree (name);


--
-- Name: ix_adventurer_characters_profession; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_profession ON public.adventurer_characters USING btree (profession);


--
-- Name: ix_adventurer_characters_rarity; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_rarity ON public.adventurer_characters USING btree (rarity);


--
-- Name: ix_adventurer_characters_unlock_order; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_unlock_order ON public.adventurer_characters USING btree (unlock_order);


--
-- Name: ix_adventurer_characters_unlock_player_level; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_adventurer_characters_unlock_player_level ON public.adventurer_characters USING btree (unlock_player_level);


--
-- Name: ix_character_conversations_character_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_character_conversations_character_id ON public.character_conversations USING btree (character_id);


--
-- Name: ix_character_conversations_player_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_character_conversations_player_id ON public.character_conversations USING btree (player_id);


--
-- Name: ix_character_unlock_logs_player_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_character_unlock_logs_player_id ON public.character_unlock_logs USING btree (player_id);


--
-- Name: ix_enchantment_logs_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_enchantment_logs_id ON public.enchantment_logs USING btree (id);


--
-- Name: ix_enchantment_materials_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_enchantment_materials_id ON public.enchantment_materials USING btree (id);


--
-- Name: ix_enchantment_types_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_enchantment_types_id ON public.enchantment_types USING btree (id);


--
-- Name: ix_mission_progress_logs_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_mission_progress_logs_id ON public.mission_progress_logs USING btree (id);


--
-- Name: ix_player_character_bonds_character_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_character_bonds_character_id ON public.player_character_bonds USING btree (character_id);


--
-- Name: ix_player_character_bonds_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_character_bonds_id ON public.player_character_bonds USING btree (id);


--
-- Name: ix_player_character_bonds_is_unlocked; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_character_bonds_is_unlocked ON public.player_character_bonds USING btree (is_unlocked);


--
-- Name: ix_player_character_bonds_player_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_character_bonds_player_id ON public.player_character_bonds USING btree (player_id);


--
-- Name: ix_player_character_bonds_trust_level; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_character_bonds_trust_level ON public.player_character_bonds USING btree (trust_level);


--
-- Name: ix_player_enchantment_materials_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_enchantment_materials_id ON public.player_enchantment_materials USING btree (id);


--
-- Name: ix_player_idle_bonuses_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_idle_bonuses_id ON public.player_idle_bonuses USING btree (id);


--
-- Name: ix_player_idle_systems_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_idle_systems_id ON public.player_idle_systems USING btree (id);


--
-- Name: ix_player_idle_upgrades_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_player_idle_upgrades_id ON public.player_idle_upgrades USING btree (id);


--
-- Name: ix_quest_area_masters_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_quest_area_masters_id ON public.quest_area_masters USING btree (id);


--
-- Name: ix_quest_area_masters_name; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_quest_area_masters_name ON public.quest_area_masters USING btree (name);


--
-- Name: ix_season_masters_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_season_masters_id ON public.season_masters USING btree (id);


--
-- Name: ix_season_masters_name; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_season_masters_name ON public.season_masters USING btree (name);


--
-- Name: ix_weapon_enchantments_id; Type: INDEX; Schema: public; Owner: bukiya_user
--

CREATE INDEX ix_weapon_enchantments_id ON public.weapon_enchantments USING btree (id);


--
-- Name: season_masters season_masters_update_trigger; Type: TRIGGER; Schema: public; Owner: bukiya_user
--

CREATE TRIGGER season_masters_update_trigger BEFORE UPDATE ON public.season_masters FOR EACH ROW EXECUTE FUNCTION public.update_season_masters_updated_at();


--
-- Name: players update_player_gold_statistics; Type: TRIGGER; Schema: public; Owner: bukiya_user
--

CREATE TRIGGER update_player_gold_statistics AFTER UPDATE ON public.players FOR EACH ROW EXECUTE FUNCTION public.update_player_statistics();


--
-- Name: players update_players_updated_at; Type: TRIGGER; Schema: public; Owner: bukiya_user
--

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON public.players FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: active_processes active_processes_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.active_processes
    ADD CONSTRAINT active_processes_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: adventurer_instances adventurer_instances_adventurer_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_instances
    ADD CONSTRAINT adventurer_instances_adventurer_master_id_fkey FOREIGN KEY (adventurer_master_id) REFERENCES public.adventurer_masters(id);


--
-- Name: adventurer_instances adventurer_instances_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_instances
    ADD CONSTRAINT adventurer_instances_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE SET NULL;


--
-- Name: adventurer_purchases adventurer_purchases_adventurer_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_purchases
    ADD CONSTRAINT adventurer_purchases_adventurer_instance_id_fkey FOREIGN KEY (adventurer_instance_id) REFERENCES public.adventurer_instances(id);


--
-- Name: adventurer_purchases adventurer_purchases_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_purchases
    ADD CONSTRAINT adventurer_purchases_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: adventurer_quests adventurer_quests_adventurer_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_quests
    ADD CONSTRAINT adventurer_quests_adventurer_instance_id_fkey FOREIGN KEY (adventurer_instance_id) REFERENCES public.adventurer_instances(id) ON DELETE CASCADE;


--
-- Name: adventurer_quests adventurer_quests_monster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_quests
    ADD CONSTRAINT adventurer_quests_monster_id_fkey FOREIGN KEY (monster_id) REFERENCES public.monster_masters(id);


--
-- Name: adventurer_quests adventurer_quests_player_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_quests
    ADD CONSTRAINT adventurer_quests_player_weapon_id_fkey FOREIGN KEY (player_weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: adventurer_quests adventurer_quests_quest_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_quests
    ADD CONSTRAINT adventurer_quests_quest_area_id_fkey FOREIGN KEY (quest_area_id) REFERENCES public.quest_area_masters(id);


--
-- Name: adventurer_requests adventurer_requests_adventurer_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_requests
    ADD CONSTRAINT adventurer_requests_adventurer_instance_id_fkey FOREIGN KEY (adventurer_instance_id) REFERENCES public.adventurer_instances(id);


--
-- Name: adventurer_requests adventurer_requests_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_requests
    ADD CONSTRAINT adventurer_requests_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: adventurer_requests adventurer_requests_weapon_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_requests
    ADD CONSTRAINT adventurer_requests_weapon_type_id_fkey FOREIGN KEY (weapon_type_id) REFERENCES public.weapon_types(id);


--
-- Name: adventurer_visits adventurer_visits_adventurer_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_visits
    ADD CONSTRAINT adventurer_visits_adventurer_master_id_fkey FOREIGN KEY (adventurer_master_id) REFERENCES public.adventurer_masters(id);


--
-- Name: adventurer_visits adventurer_visits_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.adventurer_visits
    ADD CONSTRAINT adventurer_visits_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: character_conversations character_conversations_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_conversations
    ADD CONSTRAINT character_conversations_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.adventurer_characters(id);


--
-- Name: character_conversations character_conversations_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_conversations
    ADD CONSTRAINT character_conversations_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: character_unlock_logs character_unlock_logs_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_unlock_logs
    ADD CONSTRAINT character_unlock_logs_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.adventurer_characters(id);


--
-- Name: character_unlock_logs character_unlock_logs_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.character_unlock_logs
    ADD CONSTRAINT character_unlock_logs_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: crafting_recipes crafting_recipes_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.crafting_recipes
    ADD CONSTRAINT crafting_recipes_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.weapon_masters(id);


--
-- Name: device_sessions device_sessions_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.device_sessions
    ADD CONSTRAINT device_sessions_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: enchantment_logs enchantment_logs_enchantment_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_logs
    ADD CONSTRAINT enchantment_logs_enchantment_type_id_fkey FOREIGN KEY (enchantment_type_id) REFERENCES public.enchantment_types(id);


--
-- Name: enchantment_logs enchantment_logs_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_logs
    ADD CONSTRAINT enchantment_logs_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: enchantment_logs enchantment_logs_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.enchantment_logs
    ADD CONSTRAINT enchantment_logs_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: material_masters material_masters_rarity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.material_masters
    ADD CONSTRAINT material_masters_rarity_id_fkey FOREIGN KEY (rarity_id) REFERENCES public.rarity_levels(id);


--
-- Name: material_targeting_setups material_targeting_setups_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.material_targeting_setups
    ADD CONSTRAINT material_targeting_setups_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: mission_progress_logs mission_progress_logs_mission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_progress_logs
    ADD CONSTRAINT mission_progress_logs_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES public.player_missions(id);


--
-- Name: mission_progress_logs mission_progress_logs_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.mission_progress_logs
    ADD CONSTRAINT mission_progress_logs_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: monster_drop_tables monster_drop_tables_monster_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.monster_drop_tables
    ADD CONSTRAINT monster_drop_tables_monster_master_id_fkey FOREIGN KEY (monster_master_id) REFERENCES public.monster_masters(id) ON DELETE CASCADE;


--
-- Name: monster_masters monster_masters_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.monster_masters
    ADD CONSTRAINT monster_masters_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area_masters(id);


--
-- Name: monster_masters monster_masters_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.monster_masters
    ADD CONSTRAINT monster_masters_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id);


--
-- Name: player_adventurer_relationships player_adventurer_relationships_adventurer_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_adventurer_relationships
    ADD CONSTRAINT player_adventurer_relationships_adventurer_master_id_fkey FOREIGN KEY (adventurer_master_id) REFERENCES public.adventurer_masters(id) ON DELETE CASCADE;


--
-- Name: player_adventurer_relationships player_adventurer_relationships_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_adventurer_relationships
    ADD CONSTRAINT player_adventurer_relationships_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_character_bonds player_character_bonds_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_character_bonds
    ADD CONSTRAINT player_character_bonds_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.adventurer_characters(id);


--
-- Name: player_character_bonds player_character_bonds_equipped_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_character_bonds
    ADD CONSTRAINT player_character_bonds_equipped_weapon_id_fkey FOREIGN KEY (equipped_weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: player_character_bonds player_character_bonds_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_character_bonds
    ADD CONSTRAINT player_character_bonds_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_enchantment_materials player_enchantment_materials_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_enchantment_materials
    ADD CONSTRAINT player_enchantment_materials_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.enchantment_materials(id);


--
-- Name: player_enchantment_materials player_enchantment_materials_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_enchantment_materials
    ADD CONSTRAINT player_enchantment_materials_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_idle_bonuses player_idle_bonuses_bonus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_bonuses
    ADD CONSTRAINT player_idle_bonuses_bonus_id_fkey FOREIGN KEY (bonus_id) REFERENCES public.idle_bonus_masters(id);


--
-- Name: player_idle_bonuses player_idle_bonuses_idle_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_bonuses
    ADD CONSTRAINT player_idle_bonuses_idle_system_id_fkey FOREIGN KEY (idle_system_id) REFERENCES public.player_idle_systems(id);


--
-- Name: player_idle_bonuses player_idle_bonuses_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_bonuses
    ADD CONSTRAINT player_idle_bonuses_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_idle_systems player_idle_systems_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_systems
    ADD CONSTRAINT player_idle_systems_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_idle_upgrades player_idle_upgrades_idle_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_upgrades
    ADD CONSTRAINT player_idle_upgrades_idle_system_id_fkey FOREIGN KEY (idle_system_id) REFERENCES public.player_idle_systems(id);


--
-- Name: player_idle_upgrades player_idle_upgrades_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_upgrades
    ADD CONSTRAINT player_idle_upgrades_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_idle_upgrades player_idle_upgrades_upgrade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_idle_upgrades
    ADD CONSTRAINT player_idle_upgrades_upgrade_id_fkey FOREIGN KEY (upgrade_id) REFERENCES public.idle_upgrade_masters(id);


--
-- Name: player_materials player_materials_material_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_materials
    ADD CONSTRAINT player_materials_material_master_id_fkey FOREIGN KEY (material_master_id) REFERENCES public.material_masters(id);


--
-- Name: player_materials player_materials_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_materials
    ADD CONSTRAINT player_materials_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_missions player_missions_mission_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_missions
    ADD CONSTRAINT player_missions_mission_template_id_fkey FOREIGN KEY (mission_template_id) REFERENCES public.mission_templates(id);


--
-- Name: player_missions player_missions_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_missions
    ADD CONSTRAINT player_missions_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: player_statistics player_statistics_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_statistics
    ADD CONSTRAINT player_statistics_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_weapons player_weapons_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_weapons
    ADD CONSTRAINT player_weapons_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_weapons player_weapons_weapon_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.player_weapons
    ADD CONSTRAINT player_weapons_weapon_master_id_fkey FOREIGN KEY (weapon_master_id) REFERENCES public.weapon_masters(id);


--
-- Name: quest_rewards quest_rewards_adventurer_quest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.quest_rewards
    ADD CONSTRAINT quest_rewards_adventurer_quest_id_fkey FOREIGN KEY (adventurer_quest_id) REFERENCES public.adventurer_quests(id) ON DELETE CASCADE;


--
-- Name: recipe_materials recipe_materials_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.recipe_materials
    ADD CONSTRAINT recipe_materials_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.material_masters(id);


--
-- Name: recipe_materials recipe_materials_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.recipe_materials
    ADD CONSTRAINT recipe_materials_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.crafting_recipes(id) ON DELETE CASCADE;


--
-- Name: targeting_material_weights targeting_material_weights_setup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.targeting_material_weights
    ADD CONSTRAINT targeting_material_weights_setup_id_fkey FOREIGN KEY (setup_id) REFERENCES public.material_targeting_setups(id);


--
-- Name: trade_logs trade_logs_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.trade_logs
    ADD CONSTRAINT trade_logs_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: weapon_enchantments weapon_enchantments_enchantment_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_enchantments
    ADD CONSTRAINT weapon_enchantments_enchantment_type_id_fkey FOREIGN KEY (enchantment_type_id) REFERENCES public.enchantment_types(id);


--
-- Name: weapon_enchantments weapon_enchantments_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_enchantments
    ADD CONSTRAINT weapon_enchantments_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.player_weapons(id);


--
-- Name: weapon_master_abilities weapon_master_abilities_ability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_master_abilities
    ADD CONSTRAINT weapon_master_abilities_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES public.abilities(id) ON DELETE CASCADE;


--
-- Name: weapon_masters weapon_masters_rarity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_masters
    ADD CONSTRAINT weapon_masters_rarity_id_fkey FOREIGN KEY (rarity_id) REFERENCES public.rarity_levels(id);


--
-- Name: weapon_masters weapon_masters_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_masters
    ADD CONSTRAINT weapon_masters_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season_masters(id);


--
-- Name: weapon_masters weapon_masters_weapon_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bukiya_user
--

ALTER TABLE ONLY public.weapon_masters
    ADD CONSTRAINT weapon_masters_weapon_type_id_fkey FOREIGN KEY (weapon_type_id) REFERENCES public.weapon_types(id);


--
-- PostgreSQL database dump complete
--

