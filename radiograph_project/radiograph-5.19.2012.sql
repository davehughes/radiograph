--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO radiograph;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO radiograph;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO radiograph;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO radiograph;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_group_permissions_id_seq OWNED BY auth_group_permissions.id;


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_message; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_message (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message text NOT NULL
);


ALTER TABLE public.auth_message OWNER TO radiograph;

--
-- Name: auth_message_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_message_id_seq OWNER TO radiograph;

--
-- Name: auth_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_message_id_seq OWNED BY auth_message.id;


--
-- Name: auth_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_message_id_seq', 1, false);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO radiograph;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO radiograph;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_permission_id_seq', 39, true);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(75) NOT NULL,
    password character varying(128) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    is_superuser boolean NOT NULL,
    last_login timestamp with time zone NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO radiograph;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO radiograph;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO radiograph;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_user_groups_id_seq OWNED BY auth_user_groups.id;


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO radiograph;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_user_id_seq', 2, true);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO radiograph;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO radiograph;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE auth_user_user_permissions_id_seq OWNED BY auth_user_user_permissions.id;


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('auth_user_user_permissions_id_seq', 1, false);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    content_type_id integer,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO radiograph;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO radiograph;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE django_admin_log_id_seq OWNED BY django_admin_log.id;


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE django_content_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO radiograph;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO radiograph;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE django_content_type_id_seq OWNED BY django_content_type.id;


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('django_content_type_id_seq', 13, true);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO radiograph;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.django_site OWNER TO radiograph;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE django_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_site_id_seq OWNER TO radiograph;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE django_site_id_seq OWNED BY django_site.id;


--
-- Name: django_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('django_site_id_seq', 1, true);


--
-- Name: radioapp_image; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE radioapp_image (
    id integer NOT NULL,
    aspect character varying(1) NOT NULL,
    specimen_id integer NOT NULL,
    image_full character varying(100) NOT NULL,
    image_medium character varying(100),
    image_thumbnail character varying(100),
    deleted boolean NOT NULL
);


ALTER TABLE public.radioapp_image OWNER TO radiograph;

--
-- Name: radioapp_image_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE radioapp_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.radioapp_image_id_seq OWNER TO radiograph;

--
-- Name: radioapp_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE radioapp_image_id_seq OWNED BY radioapp_image.id;


--
-- Name: radioapp_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('radioapp_image_id_seq', 1266, true);


--
-- Name: radioapp_institution; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE radioapp_institution (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    link character varying(255),
    logo character varying(100)
);


ALTER TABLE public.radioapp_institution OWNER TO radiograph;

--
-- Name: radioapp_institution_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE radioapp_institution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.radioapp_institution_id_seq OWNER TO radiograph;

--
-- Name: radioapp_institution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE radioapp_institution_id_seq OWNED BY radioapp_institution.id;


--
-- Name: radioapp_institution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('radioapp_institution_id_seq', 2, true);


--
-- Name: radioapp_specimen; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE radioapp_specimen (
    id integer NOT NULL,
    specimen_id character varying(255),
    taxon_id integer NOT NULL,
    institution_id integer NOT NULL,
    sex character varying(10),
    settings text,
    comments text,
    created date NOT NULL,
    last_modified date NOT NULL,
    skull_length numeric(10,2),
    cranial_width numeric(10,2),
    neurocranial_height numeric(10,2),
    facial_height numeric(10,2),
    palate_length numeric(10,2),
    palate_width numeric(10,2),
    created_by_id integer,
    last_modified_by_id integer,
    deleted boolean NOT NULL
);


ALTER TABLE public.radioapp_specimen OWNER TO radiograph;

--
-- Name: radioapp_specimen_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE radioapp_specimen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.radioapp_specimen_id_seq OWNER TO radiograph;

--
-- Name: radioapp_specimen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE radioapp_specimen_id_seq OWNED BY radioapp_specimen.id;


--
-- Name: radioapp_specimen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('radioapp_specimen_id_seq', 1513, true);


--
-- Name: radioapp_taxon; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE radioapp_taxon (
    id integer NOT NULL,
    parent_id integer,
    level integer NOT NULL,
    name character varying(255),
    common_name character varying(255),
    description text
);


ALTER TABLE public.radioapp_taxon OWNER TO radiograph;

--
-- Name: radioapp_taxon_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE radioapp_taxon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.radioapp_taxon_id_seq OWNER TO radiograph;

--
-- Name: radioapp_taxon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE radioapp_taxon_id_seq OWNED BY radioapp_taxon.id;


--
-- Name: radioapp_taxon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('radioapp_taxon_id_seq', 1948, true);


--
-- Name: south_migrationhistory; Type: TABLE; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE TABLE south_migrationhistory (
    id integer NOT NULL,
    app_name character varying(255) NOT NULL,
    migration character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.south_migrationhistory OWNER TO radiograph;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: radiograph
--

CREATE SEQUENCE south_migrationhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.south_migrationhistory_id_seq OWNER TO radiograph;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: radiograph
--

ALTER SEQUENCE south_migrationhistory_id_seq OWNED BY south_migrationhistory.id;


--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: radiograph
--

SELECT pg_catalog.setval('south_migrationhistory_id_seq', 3, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('auth_group_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_message ALTER COLUMN id SET DEFAULT nextval('auth_message_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_user_groups ALTER COLUMN id SET DEFAULT nextval('auth_user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('auth_user_user_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE django_admin_log ALTER COLUMN id SET DEFAULT nextval('django_admin_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE django_content_type ALTER COLUMN id SET DEFAULT nextval('django_content_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE django_site ALTER COLUMN id SET DEFAULT nextval('django_site_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE radioapp_image ALTER COLUMN id SET DEFAULT nextval('radioapp_image_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE radioapp_institution ALTER COLUMN id SET DEFAULT nextval('radioapp_institution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE radioapp_specimen ALTER COLUMN id SET DEFAULT nextval('radioapp_specimen_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE radioapp_taxon ALTER COLUMN id SET DEFAULT nextval('radioapp_taxon_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: radiograph
--

ALTER TABLE south_migrationhistory ALTER COLUMN id SET DEFAULT nextval('south_migrationhistory_id_seq'::regclass);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_message; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_message (id, user_id, message) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add permission	1	add_permission
2	Can change permission	1	change_permission
3	Can delete permission	1	delete_permission
4	Can add group	2	add_group
5	Can change group	2	change_group
6	Can delete group	2	delete_group
7	Can add user	3	add_user
8	Can change user	3	change_user
9	Can delete user	3	delete_user
10	Can add message	4	add_message
11	Can change message	4	change_message
12	Can delete message	4	delete_message
13	Can add content type	5	add_contenttype
14	Can change content type	5	change_contenttype
15	Can delete content type	5	delete_contenttype
16	Can add session	6	add_session
17	Can change session	6	change_session
18	Can delete session	6	delete_session
19	Can add site	7	add_site
20	Can change site	7	change_site
21	Can delete site	7	delete_site
22	Can add log entry	8	add_logentry
23	Can change log entry	8	change_logentry
24	Can delete log entry	8	delete_logentry
25	Can add migration history	9	add_migrationhistory
26	Can change migration history	9	change_migrationhistory
27	Can delete migration history	9	delete_migrationhistory
28	Can add taxon	10	add_taxon
29	Can change taxon	10	change_taxon
30	Can delete taxon	10	delete_taxon
31	Can add institution	11	add_institution
32	Can change institution	11	change_institution
33	Can delete institution	11	delete_institution
34	Can add specimen	12	add_specimen
35	Can change specimen	12	change_specimen
36	Can delete specimen	12	delete_specimen
37	Can add image	13	add_image
38	Can change image	13	change_image
39	Can delete image	13	delete_image
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_user (id, username, first_name, last_name, email, password, is_staff, is_active, is_superuser, last_login, date_joined) FROM stdin;
2	terry	Terry	Ritzman	tritzman@asu.edu	sha1$0b853$ae10be301f28c910109ff9363088276bcc1a5bbd	t	t	f	2012-03-05 22:58:50.342595+00	2012-03-05 22:55:33.49854+00
1	dave	David	Hughes	davehughes05@gmail.com	pbkdf2_sha256$10000$GHHMw6UKNPPT$MQ3pIpT9vKpGBG4g+5SPCi/+UtWaH+f3k2L4DEOA6DY=	t	t	t	2012-04-28 20:54:21.847684+00	2012-02-24 02:02:42.27904+00
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY django_admin_log (id, action_time, user_id, content_type_id, object_id, object_repr, action_flag, change_message) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY django_content_type (id, name, app_label, model) FROM stdin;
1	permission	auth	permission
2	group	auth	group
3	user	auth	user
4	message	auth	message
5	content type	contenttypes	contenttype
6	session	sessions	session
7	site	sites	site
8	log entry	admin	logentry
9	migration history	south	migrationhistory
10	taxon	radioapp	taxon
11	institution	radioapp	institution
12	specimen	radioapp	specimen
13	image	radioapp	image
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY django_session (session_key, session_data, expire_date) FROM stdin;
e26a6db968a8f937333bd0287fd2b731	OWU3ZDBjMjM5ZGRkZGE3YzhkNTUyMDI2MzQ2YWI0MTI0NGI0NDFlMzqAAn1xAVUKdGVzdGNvb2tp\nZVUGd29ya2VkcQJzLg==\n	2012-03-07 16:47:16.310302+00
fd0e3a7624d929a74264249691fcd715	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-05-03 05:29:28.92353+00
4fab74368df7a9f73f9b6431bba5ecdc	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-05-12 20:54:21.853056+00
f410026a2159927027c2e7285b811883	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-03-09 02:03:31.993509+00
80b6d0e7d18ba04676c2d1a000f7c30c	NTM0YjRlNTYyOWJjMGM2MmVmMzE0ODkxZGM3MDE3YWE4OWYyMjgwMDqAAn1xAS4=\n	2012-04-19 14:07:43.059463+00
ce35ac69bd549d7930145ec0271e2454	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-03-11 17:56:20.238114+00
b8a540a313372bc1384d9734d3102ca8	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-03-17 17:19:36.264613+00
9a292beac4691229cd9dbafa8cc89969	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-03-19 21:24:12.746237+00
5307fc52eb8c03c653f1d4fab343df78	YjQ3MTM3ODZmNDBhYTU2ZTM4MjdlMzJkOTJkYWVhYTZhMTAyMDE4MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZFUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxAlUN\nX2F1dGhfdXNlcl9pZEsBdS4=\n	2012-04-20 05:53:42.388084+00
89fd398b4807f7f6a1c71f2ff632902f	YzM4MjA1OTI3OWI1NjcxYmMyZjZmODYyNGVmMmFhMDhhNjdlMGVjNjqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAnUu\n	2012-03-19 21:58:37.625044+00
eec4f942f51c08ffcff67caacd1f5df1	YzM4MjA1OTI3OWI1NjcxYmMyZjZmODYyNGVmMmFhMDhhNjdlMGVjNjqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAnUu\n	2012-03-19 21:58:50.347021+00
31e9e353bce106736c42bbcd60550aa4	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-05-03 00:40:28.839058+00
4cf287c6c25b28e99c2f05d356e7ec50	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-03-25 18:04:18.423002+00
732c62df1ad65ac9019f4add300de459	YmJiMDNiNTlmOWI4NzI3Yjc2YTU0MDJmYTcwMTE1OWNmNzFkYTg1MzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQRLAXUu\n	2012-04-04 00:58:26.154213+00
\.


--
-- Data for Name: django_site; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY django_site (id, domain, name) FROM stdin;
1	example.com	example.com
\.


--
-- Data for Name: radioapp_image; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY radioapp_image (id, aspect, specimen_id, image_full, image_medium, image_thumbnail, deleted) FROM stdin;
937	L	1342	images/full/Cm32379l.tif	images/medium/937.png	images/thumbnail/937.png	f
938	S	1340	images/full/Cm32382s.tif	images/medium/938.png	images/thumbnail/938.png	f
940	S	1331	images/full/Cm26922s.tif	images/medium/940.png	images/thumbnail/940.png	f
942	S	1333	images/full/Cm32380s.tif	images/medium/942.png	images/thumbnail/942.png	f
944	L	1341	images/full/Cm32381l.tif	images/medium/944.png	images/thumbnail/944.png	f
946	L	1335	images/full/Cm32383l.tif	images/medium/946.png	images/thumbnail/946.png	f
947	L	1339	images/full/Cm30558l.tif	images/medium/947.png	images/thumbnail/947.png	f
949	L	1344	images/full/Cm37827l.tif	images/medium/949.png	images/thumbnail/949.png	f
951	S	1335	images/full/Cm32383s.tif	images/medium/951.png	images/thumbnail/951.png	f
953	S	1330	images/full/Cm30566s.tif	images/medium/953.png	images/thumbnail/953.png	f
955	S	1355	images/full/Cal41570s.tif	images/medium/955.png	images/thumbnail/955.png	f
956	L	1352	images/full/Cal39561l.tif	images/medium/956.png	images/thumbnail/956.png	f
958	L	1355	images/full/Cal41570l.tif	images/medium/958.png	images/thumbnail/958.png	f
960	L	1357	images/full/Cal30723l.tif	images/medium/960.png	images/thumbnail/960.png	f
962	L	1353	images/full/CalB-8315l.tif	images/medium/962.png	images/thumbnail/962.png	f
963	S	1354	images/full/Cal41091s.tif	images/medium/963.png	images/thumbnail/963.png	f
965	L	1354	images/full/Cal41091l.tif	images/medium/965.png	images/thumbnail/965.png	f
967	S	1352	images/full/Cal39561s.tif	images/medium/967.png	images/thumbnail/967.png	f
1004	L	1483	images/full/Ag29658l.tif	images/medium/1004.png	images/thumbnail/1004.png	f
1006	L	1482	images/full/Ag29628l.tif	images/medium/1006.png	images/thumbnail/1006.png	f
1008	S	1484	images/full/Ag5340s.tif	images/medium/1008.png	images/thumbnail/1008.png	f
1010	L	1490	images/full/Ag5145l.tif	images/medium/1010.png	images/thumbnail/1010.png	f
1012	S	1480	images/full/Ag47269s.tif	images/medium/1012.png	images/thumbnail/1012.png	f
1013	S	1489	images/full/Ag5349s.tif	images/medium/1013.png	images/thumbnail/1013.png	f
1015	L	1480	images/full/Ag47269l.tif	images/medium/1015.png	images/thumbnail/1015.png	f
1017	L	1440	images/full/So19793l.tif	images/medium/1017.png	images/thumbnail/1017.png	f
1019	S	1438	images/full/So19800s.tif	images/medium/1019.png	images/thumbnail/1019.png	f
1021	L	1437	images/full/So23826l.tif	images/medium/1021.png	images/thumbnail/1021.png	f
1023	S	1437	images/full/So23826s.tif	images/medium/1023.png	images/thumbnail/1023.png	f
1024	L	1434	images/full/So19796l.tif	images/medium/1024.png	images/thumbnail/1024.png	f
1026	S	1441	images/full/So30583s.tif	images/medium/1026.png	images/thumbnail/1026.png	f
1028	L	1435	images/full/So19798l.tif	images/medium/1028.png	images/thumbnail/1028.png	f
1030	L	1433	images/full/So19797l.tif	images/medium/1030.png	images/thumbnail/1030.png	f
1032	S	1433	images/full/So19797s.tif	images/medium/1032.png	images/thumbnail/1032.png	f
1033	S	1439	images/full/So34572s.tif	images/medium/1033.png	images/thumbnail/1033.png	f
1035	S	1348	images/full/Pm27124s.tif	images/medium/1035.png	images/thumbnail/1035.png	f
1037	L	1347	images/full/Pm30720l.tif	images/medium/1037.png	images/thumbnail/1037.png	f
1039	S	1347	images/full/Pm30720s.tif	images/medium/1039.png	images/thumbnail/1039.png	f
1094	L	1431	images/full/Sm19755l.tif	images/medium/1094.png	images/thumbnail/1094.png	f
1095	L	1428	images/full/Sm30596l.tif	images/medium/1095.png	images/thumbnail/1095.png	f
1097	S	1422	images/full/Sm30595s.tif	images/medium/1097.png	images/thumbnail/1097.png	f
1099	L	1429	images/full/Sm30592l.tif	images/medium/1099.png	images/thumbnail/1099.png	f
1101	S	1429	images/full/Sm30592s.tif	images/medium/1101.png	images/thumbnail/1101.png	f
1103	L	1453	images/full/Ch30604l.tif	images/medium/1103.png	images/thumbnail/1103.png	f
1105	L	1456	images/full/Ch30605l.tif	images/medium/1105.png	images/thumbnail/1105.png	f
1106	S	1450	images/full/Ch30586s.tif	images/medium/1106.png	images/thumbnail/1106.png	f
1108	S	1449	images/full/Ch37826s.tif	images/medium/1108.png	images/thumbnail/1108.png	f
1110	S	1455	images/full/Ch30603s.tif	images/medium/1110.png	images/thumbnail/1110.png	f
1242	L	1409	images/full/Ss27197l.tif	images/medium/1242.png	images/thumbnail/1242.png	f
1244	S	1414	images/full/Ss32358s.tif	images/medium/1244.png	images/thumbnail/1244.png	f
1245	S	1420	images/full/Ss57571s.tif	images/medium/1245.png	images/thumbnail/1245.png	f
1247	L	1420	images/full/Ss57571l.tif	images/medium/1247.png	images/thumbnail/1247.png	f
1249	S	1409	images/full/Ss27197s.tif	images/medium/1249.png	images/thumbnail/1249.png	f
1251	L	1421	images/full/Ss57570l.tif	images/medium/1251.png	images/thumbnail/1251.png	f
1253	S	1415	images/full/Ss30568s.tif	images/medium/1253.png	images/thumbnail/1253.png	f
1254	L	1419	images/full/Ss30569l.tif	images/medium/1254.png	images/thumbnail/1254.png	f
1256	S	1419	images/full/Ss30569s.tif	images/medium/1256.png	images/thumbnail/1256.png	f
1258	L	1412	images/full/Ss40981l.tif	images/medium/1258.png	images/thumbnail/1258.png	f
1260	L	1415	images/full/Ss30568l.tif	images/medium/1260.png	images/thumbnail/1260.png	f
1262	S	1410	images/full/Ss30571s.tif	images/medium/1262.png	images/thumbnail/1262.png	f
968	L	1358	images/full/CalB-8045l.tif	images/medium/968.png	images/thumbnail/968.png	f
969	S	1353	images/full/CalB-8315s.tif	images/medium/969.png	images/thumbnail/969.png	f
971	S	1462	images/full/Ab30434s.tif	images/medium/971.png	images/thumbnail/971.png	f
973	S	1457	images/full/Ab30433s.tif	images/medium/973.png	images/thumbnail/973.png	f
975	L	1464	images/full/Ab31698l.tif	images/medium/975.png	images/thumbnail/975.png	f
978	S	1466	images/full/Ab31697s.tif	images/medium/978.png	images/thumbnail/978.png	f
980	L	1458	images/full/Ab32151l.tif	images/medium/980.png	images/thumbnail/980.png	f
982	S	1463	images/full/Ab32161s.tif	images/medium/982.png	images/thumbnail/982.png	f
984	S	1460	images/full/Ab30713s.tif	images/medium/984.png	images/thumbnail/984.png	f
986	L	1457	images/full/Ab30433l.tif	images/medium/986.png	images/thumbnail/986.png	f
987	S	1467	images/full/Ab30438s.tif	images/medium/987.png	images/thumbnail/987.png	f
989	S	1464	images/full/Ab31698s.tif	images/medium/989.png	images/thumbnail/989.png	f
991	L	1486	images/full/Ag5335l.tif	images/medium/991.png	images/thumbnail/991.png	f
993	S	1491	images/full/Ag10138s.tif	images/medium/993.png	images/thumbnail/993.png	f
995	S	1488	images/full/Ag5339s.tif	images/medium/995.png	images/thumbnail/995.png	f
996	L	1485	images/full/Ag34320l.tif	images/medium/996.png	images/thumbnail/996.png	f
998	S	1485	images/full/Ag34320s.tif	images/medium/998.png	images/thumbnail/998.png	f
1000	S	1490	images/full/Ag5145s.tif	images/medium/1000.png	images/thumbnail/1000.png	f
1002	L	1488	images/full/Ag5339l.tif	images/medium/1002.png	images/thumbnail/1002.png	f
1040	L	1350	images/full/Pm5057l.tif	images/medium/1040.png	images/thumbnail/1040.png	f
1041	L	1348	images/full/Pm27124l.tif	images/medium/1041.png	images/thumbnail/1041.png	f
1043	L	1346	images/full/Pm20266l.tif	images/medium/1043.png	images/thumbnail/1043.png	f
1045	L	1468	images/full/Ac23122l.tif	images/medium/1045.png	images/thumbnail/1045.png	f
1047	S	1398	images/full/Cc34323s.tif	images/medium/1047.png	images/thumbnail/1047.png	f
1049	S	1404	images/full/Cc7324s.tif	images/medium/1049.png	images/thumbnail/1049.png	f
1050	S	1402	images/full/Cc7323s.tif	images/medium/1050.png	images/thumbnail/1050.png	f
1052	L	1391	images/full/Cc34350l.tif	images/medium/1052.png	images/thumbnail/1052.png	f
1054	S	1397	images/full/Cc5147s.tif	images/medium/1054.png	images/thumbnail/1054.png	f
1056	L	1397	images/full/Cc5147l.tif	images/medium/1056.png	images/thumbnail/1056.png	f
1058	L	1394	images/full/Cc34351l.tif	images/medium/1058.png	images/thumbnail/1058.png	f
1060	L	1403	images/full/Cc7318l.tif	images/medium/1060.png	images/thumbnail/1060.png	f
1061	S	1406	images/full/Cc5332s.tif	images/medium/1061.png	images/thumbnail/1061.png	f
1063	L	1400	images/full/Cc7321l.tif	images/medium/1063.png	images/thumbnail/1063.png	f
1065	S	1390	images/full/Cc34327s.tif	images/medium/1065.png	images/thumbnail/1065.png	f
1067	L	1396	images/full/Cc10136l.tif	images/medium/1067.png	images/thumbnail/1067.png	f
1069	S	1403	images/full/Cc7318s.tif	images/medium/1069.png	images/thumbnail/1069.png	f
1070	L	1390	images/full/Cc34327l.tif	images/medium/1070.png	images/thumbnail/1070.png	f
1072	L	1406	images/full/Cc5332l.tif	images/medium/1072.png	images/thumbnail/1072.png	f
1074	S	1401	images/full/Cc7322s.tif	images/medium/1074.png	images/thumbnail/1074.png	f
1111	L	1454	images/full/Ch30587l.tif	images/medium/1111.png	images/thumbnail/1111.png	f
1113	L	1451	images/full/Ch30576l.tif	images/medium/1113.png	images/thumbnail/1113.png	f
1115	S	1451	images/full/Ch30576s.tif	images/medium/1115.png	images/thumbnail/1115.png	f
1116	L	1455	images/full/Ch30603l.tif	images/medium/1116.png	images/thumbnail/1116.png	f
1118	S	1367	images/full/Cap32172s.tif	images/medium/1118.png	images/thumbnail/1118.png	f
1120	L	1369	images/full/Cap25811l.tif	images/medium/1120.png	images/thumbnail/1120.png	f
1122	L	1373	images/full/Cap37831l.tif	images/medium/1122.png	images/thumbnail/1122.png	f
1123	L	1374	images/full/Cap28679l.tif	images/medium/1123.png	images/thumbnail/1123.png	f
1125	L	1381	images/full/Cap30726l.tif	images/medium/1125.png	images/thumbnail/1125.png	f
1127	L	1367	images/full/Cap32172l.tif	images/medium/1127.png	images/thumbnail/1127.png	f
1128	L	1378	images/full/Cap49637l.tif	images/medium/1128.png	images/thumbnail/1128.png	f
1130	S	1386	images/full/Cap41090s.tif	images/medium/1130.png	images/thumbnail/1130.png	f
1132	S	1371	images/full/Cap49635s.tif	images/medium/1132.png	images/thumbnail/1132.png	f
1133	L	1366	images/full/Cap32173l.tif	images/medium/1133.png	images/thumbnail/1133.png	f
1135	S	1369	images/full/Cap25811s.tif	images/medium/1135.png	images/thumbnail/1135.png	f
1137	L	1377	images/full/Cap39566l.tif	images/medium/1137.png	images/thumbnail/1137.png	f
1139	L	1362	images/full/Cap31070l.tif	images/medium/1139.png	images/thumbnail/1139.png	f
1140	L	1363	images/full/Cap31071l.tif	images/medium/1140.png	images/thumbnail/1140.png	f
1142	L	1371	images/full/Cap49635l.tif	images/medium/1142.png	images/thumbnail/1142.png	f
1144	S	1377	images/full/Cap39566s.tif	images/medium/1144.png	images/thumbnail/1144.png	f
1145	L	1380	images/full/Cap30724l.tif	images/medium/1145.png	images/thumbnail/1145.png	f
1147	S	1376	images/full/Cap15325s.tif	images/medium/1147.png	images/thumbnail/1147.png	f
1076	S	1394	images/full/Cc34351s.tif	images/medium/1076.png	images/thumbnail/1076.png	f
1078	S	1393	images/full/Cc29637s.tif	images/medium/1078.png	images/thumbnail/1078.png	f
1080	S	1400	images/full/Cc7321s.tif	images/medium/1080.png	images/thumbnail/1080.png	f
1081	L	1395	images/full/Cc10135l.tif	images/medium/1081.png	images/thumbnail/1081.png	f
1083	L	1427	images/full/Sm30601l.tif	images/medium/1083.png	images/thumbnail/1083.png	f
1085	L	1424	images/full/Sm30593l.tif	images/medium/1085.png	images/thumbnail/1085.png	f
1087	L	1425	images/full/Sm30597l.tif	images/medium/1087.png	images/thumbnail/1087.png	f
1089	S	1427	images/full/Sm30601s.tif	images/medium/1089.png	images/thumbnail/1089.png	f
1090	L	1426	images/full/Sm30599l.tif	images/medium/1090.png	images/thumbnail/1090.png	f
934	L	1333	images/full/Cm32380l.tif	images/medium/934.png	images/thumbnail/934.png	f
935	S	1338	images/full/Cm27208s.tif	images/medium/935.png	images/thumbnail/935.png	f
936	S	1342	images/full/Cm32379s.tif	images/medium/936.png	images/thumbnail/936.png	f
939	S	1339	images/full/Cm30558s.tif	images/medium/939.png	images/thumbnail/939.png	f
941	L	1343	images/full/Cm30565l.tif	images/medium/941.png	images/thumbnail/941.png	f
943	L	1337	images/full/Cm30559l.tif	images/medium/943.png	images/thumbnail/943.png	f
945	S	1343	images/full/Cm30565s.tif	images/medium/945.png	images/thumbnail/945.png	f
948	L	1330	images/full/Cm30566l.tif	images/medium/948.png	images/thumbnail/948.png	f
1149	L	1364	images/full/Cap31073l.tif	images/medium/1149.png	images/thumbnail/1149.png	f
1151	L	1386	images/full/Cap41090l.tif	images/medium/1151.png	images/thumbnail/1151.png	f
1152	L	1384	images/full/Cap62375l.tif	images/medium/1152.png	images/thumbnail/1152.png	f
1154	L	1359	images/full/Cap31068l.tif	images/medium/1154.png	images/thumbnail/1154.png	f
1156	S	1368	images/full/Cap32176s.tif	images/medium/1156.png	images/thumbnail/1156.png	f
1157	S	1383	images/full/Cap31066s.tif	images/medium/1157.png	images/thumbnail/1157.png	f
1159	L	1383	images/full/Cap31066l.tif	images/medium/1159.png	images/thumbnail/1159.png	f
1161	S	1359	images/full/Cap31068s.tif	images/medium/1161.png	images/thumbnail/1161.png	f
1162	S	1361	images/full/Cap32175s.tif	images/medium/1162.png	images/thumbnail/1162.png	f
1164	S	1389	images/full/Cap27892s.tif	images/medium/1164.png	images/thumbnail/1164.png	f
1166	S	1366	images/full/Cap32173s.tif	images/medium/1166.png	images/thumbnail/1166.png	f
1168	S	1380	images/full/Cap30724s.tif	images/medium/1168.png	images/thumbnail/1168.png	f
1169	S	1387	images/full/Cap27891s.tif	images/medium/1169.png	images/thumbnail/1169.png	f
1171	S	1370	images/full/Cap32050s.tif	images/medium/1171.png	images/thumbnail/1171.png	f
1173	L	1385	images/full/Cap61631l.tif	images/medium/1173.png	images/thumbnail/1173.png	f
1174	S	1382	images/full/Cap31072s.tif	images/medium/1174.png	images/thumbnail/1174.png	f
1178	L	1360	images/full/Cap27097l.tif	images/medium/1178.png	images/thumbnail/1178.png	f
1180	L	1444	images/full/Ca30580l.tif	images/medium/1180.png	images/thumbnail/1180.png	f
1181	S	1442	images/full/Ca32163s.tif	images/medium/1181.png	images/thumbnail/1181.png	f
1183	L	1448	images/full/Ca30579l.tif	images/medium/1183.png	images/thumbnail/1183.png	f
1185	S	1447	images/full/Ca30582s.tif	images/medium/1185.png	images/thumbnail/1185.png	f
1187	S	1444	images/full/Ca30580s.tif	images/medium/1187.png	images/thumbnail/1187.png	f
1189	L	1446	images/full/Ca32165l.tif	images/medium/1189.png	images/thumbnail/1189.png	f
1190	L	1441	images/full/Ca30583l.tif	images/medium/1190.png	images/thumbnail/1190.png	f
1192	S	1443	images/full/Ca30578s.tif	images/medium/1192.png	images/thumbnail/1192.png	f
1194	S	1445	images/full/Ca32164s.tif	images/medium/1194.png	images/thumbnail/1194.png	f
1196	S	1320	images/full/At25608s.tif	images/medium/1196.png	images/thumbnail/1196.png	f
1198	L	1319	images/full/At19802l.tif	images/medium/1198.png	images/thumbnail/1198.png	f
1199	L	1320	images/full/At25608l.tif	images/medium/1199.png	images/thumbnail/1199.png	f
1201	S	1323	images/full/At30562s.tif	images/medium/1201.png	images/thumbnail/1201.png	f
1203	S	1326	images/full/At39571s.tif	images/medium/1203.png	images/thumbnail/1203.png	f
1205	L	1328	images/full/At19801l.tif	images/medium/1205.png	images/thumbnail/1205.png	f
1207	S	1325	images/full/At19805s.tif	images/medium/1207.png	images/thumbnail/1207.png	f
1208	L	1324	images/full/At27214l.tif	images/medium/1208.png	images/thumbnail/1208.png	f
1210	L	1322	images/full/AtB-8043l.tif	images/medium/1210.png	images/thumbnail/1210.png	f
1212	S	1322	images/full/AtB-8043s.tif	images/medium/1212.png	images/thumbnail/1212.png	f
1214	S	1327	images/full/AtB-0842s.tif	images/medium/1214.png	images/thumbnail/1214.png	f
1216	L	1471	images/full/Ap29546l.tif	images/medium/1216.png	images/thumbnail/1216.png	f
1217	L	1475	images/full/Ap27784l.tif	images/medium/1217.png	images/thumbnail/1217.png	f
1219	S	1476	images/full/Ap5149s.tif	images/medium/1219.png	images/thumbnail/1219.png	f
1221	S	1471	images/full/Ap29546s.tif	images/medium/1221.png	images/thumbnail/1221.png	f
1223	L	1326	images/full/At39571l_1.tif	images/medium/1223.png	images/thumbnail/1223.png	f
1225	L	1472	images/full/Ap29050l.tif	images/medium/1225.png	images/thumbnail/1225.png	f
1226	S	1472	images/full/Ap29050s.tif	images/medium/1226.png	images/thumbnail/1226.png	f
1228	S	1478	images/full/Ap7315s.tif	images/medium/1228.png	images/thumbnail/1228.png	f
1230	S	1469	images/full/Ap47266s.tif	images/medium/1230.png	images/thumbnail/1230.png	f
1232	S	1477	images/full/Ap7316s.tif	images/medium/1232.png	images/thumbnail/1232.png	f
1234	L	1469	images/full/Ap47266l.tif	images/medium/1234.png	images/thumbnail/1234.png	f
1235	S	1470	images/full/Ap28736s.tif	images/medium/1235.png	images/thumbnail/1235.png	f
1237	L	1416	images/full/Ss30570l.tif	images/medium/1237.png	images/thumbnail/1237.png	f
1239	S	1411	images/full/Ss30573s.tif	images/medium/1239.png	images/thumbnail/1239.png	f
926	L	1340	images/full/Cm32382l.tif	images/medium/926.png	images/thumbnail/926.png	f
928	S	1344	images/full/Cm37827s.tif	images/medium/928.png	images/thumbnail/928.png	f
929	S	1334	images/full/Cm39563s.tif	images/medium/929.png	images/thumbnail/929.png	f
931	L	1336	images/full/Cm37828l.tif	images/medium/931.png	images/thumbnail/931.png	f
933	L	1334	images/full/Cm39563l.tif	images/medium/933.png	images/thumbnail/933.png	f
1096	L	1423	images/full/Sm30590l.tif	images/medium/1096.png	images/thumbnail/1096.png	f
1255	S	1418	images/full/Ss30567s.tif	images/medium/1255.png	images/thumbnail/1255.png	f
976	S	1459	images/full/Ab30431s.tif	images/medium/976.png	images/thumbnail/976.png	f
977	L	1462	images/full/Ab30434l.tif	images/medium/977.png	images/thumbnail/977.png	f
1042	S	1349	images/full/Pm30721s.tif	images/medium/1042.png	images/thumbnail/1042.png	f
1051	L	1398	images/full/Cc34323l.tif	images/medium/1051.png	images/thumbnail/1051.png	f
952	S	1337	images/full/Cm30559s.tif	images/medium/952.png	images/thumbnail/952.png	f
954	S	1336	images/full/Cm37828s.tif	images/medium/954.png	images/thumbnail/954.png	f
957	S	1358	images/full/CalB-8045s.tif	images/medium/957.png	images/thumbnail/957.png	f
959	S	1357	images/full/Cal30723s.tif	images/medium/959.png	images/thumbnail/959.png	f
961	L	1351	images/full/CalB-8316l.tif	images/medium/961.png	images/thumbnail/961.png	f
964	L	1356	images/full/Cal30725l.tif	images/medium/964.png	images/thumbnail/964.png	f
966	S	1356	images/full/Cal30725s.tif	images/medium/966.png	images/thumbnail/966.png	f
1005	L	1484	images/full/Ag5340l.tif	images/medium/1005.png	images/thumbnail/1005.png	f
1007	S	1479	images/full/Ag29642s.tif	images/medium/1007.png	images/thumbnail/1007.png	f
1011	L	1491	images/full/Ag10138l.tif	images/medium/1011.png	images/thumbnail/1011.png	f
1014	L	1487	images/full/Ag5338l.tif	images/medium/1014.png	images/thumbnail/1014.png	f
1016	L	1436	images/full/So19792l.tif	images/medium/1016.png	images/thumbnail/1016.png	f
1018	S	1440	images/full/So19793s.tif	images/medium/1018.png	images/thumbnail/1018.png	f
1020	S	1436	images/full/So19792s.tif	images/medium/1020.png	images/thumbnail/1020.png	f
1022	S	1435	images/full/So19798s.tif	images/medium/1022.png	images/thumbnail/1022.png	f
1025	L	1439	images/full/So34572l.tif	images/medium/1025.png	images/thumbnail/1025.png	f
1027	L	1432	images/full/So19795l.tif	images/medium/1027.png	images/thumbnail/1027.png	f
1029	S	1432	images/full/So19795s.tif	images/medium/1029.png	images/thumbnail/1029.png	f
1031	L	1438	images/full/So19800l.tif	images/medium/1031.png	images/thumbnail/1031.png	f
1034	S	1434	images/full/So19796s.tif	images/medium/1034.png	images/thumbnail/1034.png	f
1036	S	1346	images/full/Pm20266s.tif	images/medium/1036.png	images/thumbnail/1036.png	f
1038	S	1350	images/full/Pm5057s.tif	images/medium/1038.png	images/thumbnail/1038.png	f
1093	L	1430	images/full/Sm30602l.tif	images/medium/1093.png	images/thumbnail/1093.png	f
1098	S	1430	images/full/Sm30602s.tif	images/medium/1098.png	images/thumbnail/1098.png	f
1100	L	1422	images/full/Sm30595l.tif	images/medium/1100.png	images/thumbnail/1100.png	f
1102	S	1428	images/full/Sm30596s.tif	images/medium/1102.png	images/thumbnail/1102.png	f
1104	S	1453	images/full/Ch30604s.tif	images/medium/1104.png	images/thumbnail/1104.png	f
1107	L	1449	images/full/Ch37826l.tif	images/medium/1107.png	images/thumbnail/1107.png	f
1109	L	1450	images/full/Ch30586l.tif	images/medium/1109.png	images/thumbnail/1109.png	f
1241	L	1417	images/full/Ss30575l.tif	images/medium/1241.png	images/thumbnail/1241.png	f
1243	S	1421	images/full/Ss57570s.tif	images/medium/1243.png	images/thumbnail/1243.png	f
1246	S	1412	images/full/Ss40981s.tif	images/medium/1246.png	images/thumbnail/1246.png	f
1248	S	1408	images/full/Ss30572s.tif	images/medium/1248.png	images/thumbnail/1248.png	f
1250	L	1411	images/full/Ss30573l.tif	images/medium/1250.png	images/thumbnail/1250.png	f
1252	L	1414	images/full/Ss32358l.tif	images/medium/1252.png	images/thumbnail/1252.png	f
1257	L	1410	images/full/Ss30571l.tif	images/medium/1257.png	images/thumbnail/1257.png	f
1259	L	1413	images/full/Ss40979l.tif	images/medium/1259.png	images/thumbnail/1259.png	f
1263	L	1418	images/full/Ss30567l.tif	images/medium/1263.png	images/thumbnail/1263.png	f
970	S	1351	images/full/CalB-8316s.tif	images/medium/970.png	images/thumbnail/970.png	f
972	L	1463	images/full/Ab32161l.tif	images/medium/972.png	images/thumbnail/972.png	f
974	S	1465	images/full/Ab30439s.tif	images/medium/974.png	images/thumbnail/974.png	f
979	L	1460	images/full/Ab30713l.tif	images/medium/979.png	images/thumbnail/979.png	f
981	L	1465	images/full/Ab30439l.tif	images/medium/981.png	images/thumbnail/981.png	f
983	L	1466	images/full/Ab31697l.tif	images/medium/983.png	images/thumbnail/983.png	f
985	S	1458	images/full/Ab32151s.tif	images/medium/985.png	images/thumbnail/985.png	f
988	L	1467	images/full/Ab30438l.tif	images/medium/988.png	images/thumbnail/988.png	f
990	S	1486	images/full/Ag5335s.tif	images/medium/990.png	images/thumbnail/990.png	f
992	L	1489	images/full/Ag5349l.tif	images/medium/992.png	images/thumbnail/992.png	f
994	S	1487	images/full/Ag5338s.tif	images/medium/994.png	images/thumbnail/994.png	f
997	S	1483	images/full/Ag29658s.tif	images/medium/997.png	images/thumbnail/997.png	f
999	S	1481	images/full/Ag34322s.tif	images/medium/999.png	images/thumbnail/999.png	f
1001	S	1482	images/full/Ag29628s.tif	images/medium/1001.png	images/thumbnail/1001.png	f
1003	L	1479	images/full/Ag29642l.tif	images/medium/1003.png	images/thumbnail/1003.png	f
1044	L	1349	images/full/Pm30721l.tif	images/medium/1044.png	images/thumbnail/1044.png	f
1046	S	1468	images/full/Ac23122s.tif	images/medium/1046.png	images/thumbnail/1046.png	f
1048	L	1401	images/full/Cc7322l.tif	images/medium/1048.png	images/thumbnail/1048.png	f
1053	L	1392	images/full/Cc34324l.tif	images/medium/1053.png	images/thumbnail/1053.png	f
1055	L	1402	images/full/Cc7323l.tif	images/medium/1055.png	images/thumbnail/1055.png	f
1057	L	1407	images/full/Cc5148l.tif	images/medium/1057.png	images/thumbnail/1057.png	f
1059	S	1395	images/full/Cc10135s.tif	images/medium/1059.png	images/thumbnail/1059.png	f
1071	S	1399	images/full/Cc34353s.tif	images/medium/1071.png	images/thumbnail/1071.png	f
1134	L	1379	images/full/Cap31064l.tif	images/medium/1134.png	images/thumbnail/1134.png	f
1092	S	1423	images/full/Sm30590s.tif	images/medium/1092.png	images/thumbnail/1092.png	f
1163	S	1388	images/full/Cap30722s.tif	images/medium/1163.png	images/thumbnail/1163.png	f
1200	S	1321	images/full/At30560s.tif	images/medium/1200.png	images/thumbnail/1200.png	f
1209	L	1321	images/full/At30560l.tif	images/medium/1209.png	images/thumbnail/1209.png	f
950	L	1332	images/full/Cm30564l.tif	images/medium/950.png	images/thumbnail/950.png	f
1176	S	1365	images/full/Cap32174s.tif	images/medium/1176.png	images/thumbnail/1176.png	f
1009	L	1481	images/full/Ag34322l.tif	images/medium/1009.png	images/thumbnail/1009.png	f
1261	S	1413	images/full/Ss40979s.tif	images/medium/1261.png	images/thumbnail/1261.png	f
1062	S	1391	images/full/Cc34350s.tif	images/medium/1062.png	images/thumbnail/1062.png	f
1064	L	1404	images/full/Cc7324l.tif	images/medium/1064.png	images/thumbnail/1064.png	f
1066	L	1405	images/full/Cc7317l.tif	images/medium/1066.png	images/thumbnail/1066.png	f
1068	S	1396	images/full/Cc10136s.tif	images/medium/1068.png	images/thumbnail/1068.png	f
1073	S	1405	images/full/Cc7317s.tif	images/medium/1073.png	images/thumbnail/1073.png	f
1112	S	1456	images/full/Ch30605s.tif	images/medium/1112.png	images/thumbnail/1112.png	f
1114	S	1452	images/full/Ch30577s.tif	images/medium/1114.png	images/thumbnail/1114.png	f
1117	L	1452	images/full/Ch30577l.tif	images/medium/1117.png	images/thumbnail/1117.png	f
1119	S	1384	images/full/Cap62375s.tif	images/medium/1119.png	images/thumbnail/1119.png	f
1121	L	1382	images/full/Cap31072l.tif	images/medium/1121.png	images/thumbnail/1121.png	f
1124	S	1372	images/full/Cap37829s.tif	images/medium/1124.png	images/thumbnail/1124.png	f
1126	S	1364	images/full/Cap31073s.tif	images/medium/1126.png	images/thumbnail/1126.png	f
1129	S	1374	images/full/Cap28679s.tif	images/medium/1129.png	images/thumbnail/1129.png	f
1131	L	1368	images/full/Cap32176l.tif	images/medium/1131.png	images/thumbnail/1131.png	f
1136	L	1376	images/full/Cap15325l.tif	images/medium/1136.png	images/thumbnail/1136.png	f
1138	S	1381	images/full/Cap30726s.tif	images/medium/1138.png	images/thumbnail/1138.png	f
1141	L	1370	images/full/Cap32050l.tif	images/medium/1141.png	images/thumbnail/1141.png	f
1143	S	1379	images/full/Cap31064s.tif	images/medium/1143.png	images/thumbnail/1143.png	f
1146	S	1375	images/full/Cap37833s.tif	images/medium/1146.png	images/thumbnail/1146.png	f
1264	S	1417	images/full/Ss30575s.tif	images/medium/1264.png	images/thumbnail/1264.png	f
1077	L	1399	images/full/Cc34353l.tif	images/medium/1077.png	images/thumbnail/1077.png	f
1079	S	1392	images/full/Cc34324s.tif	images/medium/1079.png	images/thumbnail/1079.png	f
1082	S	1407	images/full/Cc5148s.tif	images/medium/1082.png	images/thumbnail/1082.png	f
1084	S	1426	images/full/Sm30599s.tif	images/medium/1084.png	images/thumbnail/1084.png	f
1086	S	1425	images/full/Sm30597s.tif	images/medium/1086.png	images/thumbnail/1086.png	f
1088	S	1424	images/full/Sm30593s.tif	images/medium/1088.png	images/thumbnail/1088.png	f
1091	S	1431	images/full/Sm19755s.tif	images/medium/1091.png	images/thumbnail/1091.png	f
1148	S	1373	images/full/Cap37831s.tif	images/medium/1148.png	images/thumbnail/1148.png	f
1150	L	1365	images/full/Cap32174l.tif	images/medium/1150.png	images/thumbnail/1150.png	f
1153	L	1372	images/full/Cap37829l.tif	images/medium/1153.png	images/thumbnail/1153.png	f
1155	L	1361	images/full/Cap32175l.tif	images/medium/1155.png	images/thumbnail/1155.png	f
1158	S	1378	images/full/Cap49637s.tif	images/medium/1158.png	images/thumbnail/1158.png	f
1160	L	1387	images/full/Cap27891l.tif	images/medium/1160.png	images/thumbnail/1160.png	f
1167	L	1388	images/full/Cap30722l.tif	images/medium/1167.png	images/thumbnail/1167.png	f
1170	S	1385	images/full/Cap61631s.tif	images/medium/1170.png	images/thumbnail/1170.png	f
1172	L	1375	images/full/Cap37833l.tif	images/medium/1172.png	images/thumbnail/1172.png	f
1175	S	1363	images/full/Cap31071s.tif	images/medium/1175.png	images/thumbnail/1175.png	f
1177	S	1360	images/full/Cap27097s.tif	images/medium/1177.png	images/thumbnail/1177.png	f
1179	S	1362	images/full/Cap31070s.tif	images/medium/1179.png	images/thumbnail/1179.png	f
1182	L	1447	images/full/Ca30582l.tif	images/medium/1182.png	images/thumbnail/1182.png	f
1184	S	1446	images/full/Ca32165s.tif	images/medium/1184.png	images/thumbnail/1184.png	f
1186	S	1448	images/full/Ca30579s.tif	images/medium/1186.png	images/thumbnail/1186.png	f
1188	L	1443	images/full/Ca30578l.tif	images/medium/1188.png	images/thumbnail/1188.png	f
1191	L	1442	images/full/Ca32163l.tif	images/medium/1191.png	images/thumbnail/1191.png	f
1193	S	1441	images/full/Ca30583s.tif	images/medium/1193.png	images/thumbnail/1193.png	f
1195	L	1325	images/full/At19805l.tif	images/medium/1195.png	images/thumbnail/1195.png	f
1197	S	1324	images/full/At27214s.tif	images/medium/1197.png	images/thumbnail/1197.png	f
1202	L	1323	images/full/At30562l.tif	images/medium/1202.png	images/thumbnail/1202.png	f
1204	L	1326	images/full/At39571l.tif	images/medium/1204.png	images/thumbnail/1204.png	f
1206	L	1327	images/full/AtB-0842l.tif	images/medium/1206.png	images/thumbnail/1206.png	f
1211	S	1319	images/full/At19802s.tif	images/medium/1211.png	images/thumbnail/1211.png	f
1213	S	1328	images/full/At19801s.tif	images/medium/1213.png	images/thumbnail/1213.png	f
1215	S	1324	images/full/At27214s_1.tif	images/medium/1215.png	images/thumbnail/1215.png	f
1218	S	1473	images/full/Ap28735s.tif	images/medium/1218.png	images/thumbnail/1218.png	f
1220	L	1476	images/full/Ap5149l.tif	images/medium/1220.png	images/thumbnail/1220.png	f
1222	L	1473	images/full/Ap28735l.tif	images/medium/1222.png	images/thumbnail/1222.png	f
1224	S	1474	images/full/Ap29544s.tif	images/medium/1224.png	images/thumbnail/1224.png	f
1231	L	1478	images/full/Ap7315l.tif	images/medium/1231.png	images/thumbnail/1231.png	f
1233	L	1477	images/full/Ap7316l.tif	images/medium/1233.png	images/thumbnail/1233.png	f
1236	S	1475	images/full/Ap27784s.tif	images/medium/1236.png	images/thumbnail/1236.png	f
1238	L	1408	images/full/Ss30572l.tif	images/medium/1238.png	images/thumbnail/1238.png	f
1240	S	1416	images/full/Ss30570s.tif	images/medium/1240.png	images/thumbnail/1240.png	f
927	S	1341	images/full/Cm32381s.tif	images/medium/927.png	images/thumbnail/927.png	f
930	L	1338	images/full/Cm27208l.tif	images/medium/930.png	images/thumbnail/930.png	f
932	L	1331	images/full/Cm26922l.tif	images/medium/932.png	images/thumbnail/932.png	f
1075	L	1393	images/full/Cc29637l.tif	images/medium/1075.png	images/thumbnail/1075.png	f
1165	L	1389	images/full/Cap27892l.tif	images/medium/1165.png	images/thumbnail/1165.png	f
1227	L	1474	images/full/Ap29544l.tif	images/medium/1227.png	images/thumbnail/1227.png	f
1229	L	1470	images/full/Ap28736l.tif	images/medium/1229.png	images/thumbnail/1229.png	f
\.


--
-- Data for Name: radioapp_institution; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY radioapp_institution (id, name, link, logo) FROM stdin;
1	Harvard	\N	
2	Smithsonian Institution	http://www.mnh.si.edu/	
\.


--
-- Data for Name: radioapp_specimen; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY radioapp_specimen (id, specimen_id, taxon_id, institution_id, sex, settings, comments, created, last_modified, skull_length, cranial_width, neurocranial_height, facial_height, palate_length, palate_width, created_by_id, last_modified_by_id, deleted) FROM stdin;
1319	19802	1594	1	M	85kV; 34uA	Original classification: Aotus trivirgatus griseimembra	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1320	25608	1594	1	M	85kV; 34uA	Updated specimen ID from original: 25608	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1321	30560	1594	1	M	85kV; 34uA	Original classification: Aotus trivirgatus infulatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1322	B-8043	1594	1	M	85kV; 34uA	Original classification: Aotus trivirgatus infulatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1323	30562	1594	1	F	85kV; 34uA	Original classification: Aotus trivirgatus infulatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1324	27214	1594	1	F	85kV; 34uA	Original classification: Aotus trivirgatus griseimembra	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1325	19805	1594	1	F	85kV; 34uA	Original classification: Aotus trivirgatus griseimembra	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1326	39571	1594	1	F	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1327	B-0842	1594	1	F	85kV; 34uA	Specimen ID updated from original: B-8042\n\nOriginal classification: Aotus trivirgatus infulatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1328	19801	1594	1	F	85kV; 34uA	Original classification: Aotus trivirgatus griseimembra	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1329	39073	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1330	30566	1598	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1331	26922	1598	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1332	30564	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1333	32380	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1334	39563	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch brunneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1335	32383	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch brunneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1336	37828	1598	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1337	30559	1598	1	M	85kV; 34uA	Original classification: Callicebus moloch hoffmannsi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1338	27208	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch ornatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1339	30558	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch hoffmannsi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1340	32382	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1341	32381	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1342	32379	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1343	30565	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch nemulus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1344	37827	1598	1	F	85kV; 34uA	Original classification: Callicebus moloch pallescens	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1351	B-8316	1547	1	M	85kV; 34uA	Original classification: Cebus albifrons malitiosus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1352	39561	1550	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1353	B-8315	1547	1	M	85kV; 34uA	Original classification: Cebus albifrons malitiosus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1354	41091	1550	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1355	41570	1547	1	M	85kV; 34uA	Original classification: Cebus albifrons yuracus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1356	30725	1552	1	F	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1357	30723	1552	1	F	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1358	B-8045	1547	1	F	85kV; 34uA	Original classification: Cebus albifrons malitiosus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1359	31068	1557	1	M	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1360	27097	1554	1	M	85kV; 34uA	Original classification: Cebus apella paraguayanus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1361	32175	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1362	31070	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1363	31071	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1364	31073	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1365	32174	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1366	32173	1557	1	M	95kV; 30uA	Not included in original spreadsheet	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1367	32172	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1368	32176	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1369	25811	1554	1	M	95kV; 30uA	Original classification: Cebus apella nigritas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1370	32050	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1371	49635	1554	1	M	95kV; 30uA	Original classification: Cebus apella robustus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1372	37829	1557	1	M	95kV; 30uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1373	37831	1554	1	M	95kV; 30uA	Original classification: Cebus apella frontatus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1374	28679	1554	1	M	95kV; 30uA	Original classification: Cebus apella paraguayanus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1375	37833	1554	1	M	95kV; 25uA	new settings started on lateral x-ray\n\nOriginal classification: Cebus apella nigritas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1376	15325	1554	1	M	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1377	39566	1554	1	M	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1378	49637	1554	1	M	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1379	31064	1557	1	F	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1380	30724	1557	1	F	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1381	30726	1557	1	F	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1382	31072	1557	1	F	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1383	31066	1554	1	F	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1384	62375	1554	1	F	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1385	61631	1554	1	F	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1386	41090	1554	1	F	95kV; 25uA	Original classification: Cebus apella --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1390	34327	1560	1	M	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1391	34350	1560	1	M	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1392	34324	1560	1	M	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1393	29637	1560	1	M	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1394	34351	1560	1	M	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1395	10135	1560	1	F	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1396	10136	1560	1	F	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1397	5147	1560	1	F	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1398	34323	1560	1	F	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1399	34353	1560	1	F	95kV; 25uA	Original classification: Cebus capucinus imitator	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1408	30572	1581	1	M	105kV; 22uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1409	27197	1580	1	M	105kV; 22uA	Original classification: Saimiri sciureus caquetensis	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1410	30571	1581	1	M	105kV; 22uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1411	30573	1580	1	M	105kV; 22uA	Original classification: Saimiri sciureus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1412	40981	1580	1	M	105kV; 22uA	Original classification: Saimiri sciureus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1413	40979	1580	1	M	105kV; 22uA	Original classification: Saimiri sciureus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1414	32358	1580	1	M	105kV; 22uA	Original classification: Saimiri sciureus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1415	30568	1581	1	F	105kV; 22uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1416	30570	1581	1	F	105kV; 22uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1417	30575	1580	1	F	105kV; 22uA	Original classification: Saimiri sciureus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1418	30567	1580	1	F	105kV; 22uA	Original classification: Saimiri sciureus boliveiensis?	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1419	30569	1581	1	M	105kV; 22uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1422	30595	1535	1	M	105kV; 22uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1423	30590	1535	1	M	105kV; 22uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1424	30593	1535	1	M	105kV; 22uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1425	30597	1535	1	M	94kV; 25uA	new settings started on lateral x-ray\n\nOriginal classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1426	30599	1535	1	F	94kV; 25uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1427	30601	1535	1	F	94kV; 25uA	Original classification: Saguinus midas tamarin	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1428	30596	1535	1	F	94kV; 25uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1429	30592	1535	1	F	94kV; 25uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1430	30602	1535	1	F	94kV; 25uA	Original classification: Saguinus midas tamarin	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1432	19795	1544	1	M	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1433	19797	1544	1	M	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1434	19796	1544	1	F	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1435	19798	1544	1	F	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1436	19792	1544	1	F	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1441	30583	1511	1	M	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1449	37826	1512	1	M	94kV; 25uA	Original classification: Callithrix humeralifera --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1450	30586	1512	1	M	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1451	30576	1512	1	M	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1452	30577	1512	1	F	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1453	30604	1512	1	F	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1454	30587	1512	1	F	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1455	30603	1512	1	F	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1456	30605	1512	1	F	94kV; 25uA	Original classification: Callithrix humeralifera humeralifer	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1457	30433	1617	1	M	125kV; 16uA	new settings started on lateral x-ray\n\nOriginal classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1458	32151	1617	1	M	130kV; 15uA	new settings started on lateral x-ray\n\nOriginal classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1459	30431	1617	1	M	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1460	30713	1617	1	M	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1461	30715	1617	1	M	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1462	30434	1617	1	M	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1463	32161	1617	1	M	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1464	31698	1617	1	F	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1466	31697	1617	1	F	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1467	30438	1617	1	F	130kV; 15uA	Original classification: Alouatta belzebul --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1468	23122	1618	1	F	130kV; 15uA	Original classification: Alouatta caraya --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1469	47266	1625	1	M	130kV; 15uA	Original classification: Alouatta palliata pigra	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1470	28736	1625	1	M	130kV; 15uA	Original classification: Alouatta palliata trabeata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1471	29546	1625	1	M	130kV; 15uA	Original classification: Alouatta palliata trabeata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1472	29050	1625	1	F	130kV; 15uA	Original classification: Alouatta palliata aequatorialis	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1473	28735	1625	1	F	130kV; 15uA	Original classification: Alouatta palliata trabeata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1474	29544	1625	1	F	130kV; 15uA	Original classification: Alouatta palliata trabeata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1475	27784	1625	1	F	130kV; 15uA	Original classification: Alouatta palliata trabeata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1479	29642	1638	1	M	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1480	47269	1638	1	F	130kV; 15uA	Original classification: Ateles geoffroyi vellorosus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1481	34322	1638	1	F	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1482	29628	1638	1	F	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1483	29658	1638	1	F	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1345	5057(?)	1608	1	U	85kV; 34uA	Original classification: Pithecia monachus Humboldt(?)	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1346	20266	1608	1	U	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1347	30720	1608	1	U	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1348	27124	1608	1	U	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1349	30721	1608	1	U	85kV; 34uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1350	5057	1608	1	U	85kV; 34uA	Not included in original spreadsheet	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1387	27891	1555	1	U	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1388	30722	1557	1	U	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1389	27892	1555	1	U	95kV; 25uA		2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1400	7321	1560	1	U	95kV; 25uA	Not included in original spreadsheet\n\nOriginal classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1401	7322	1560	1	U	95kV; 25uA	Original classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1402	7323	1560	1	U	95kV; 25uA	Not included in original spreadsheet\n\nOriginal classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1403	7318	1560	1	U	95kV; 25uA	Original classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1404	7324	1560	1	U	95kV; 25uA	Original classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1405	7317	1560	1	U	95kV; 25uA	Original classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1406	5332	1560	1	U	105kV; 22uA	new settings started on lateral x-ray; Updated specimen ID from original: 5322\n\nOriginal classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1407	5148	1560	1	U	105kV; 22uA	Original classification: Cebus capucinus limitaneus	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1420	57571	1580	1	U	105kV; 22uA	Original classification: Saimiri sciureus macrodon?	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1421	57570	1580	1	U	105kV; 22uA	M1 missing; M2 used for aligning lateral x-ray\n\nOriginal classification: Saimiri sciureus macrodon?	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1431	19755	1535	1	U	94kV; 25uA	Original classification: Saguinus midas midas	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1437	23826	1544	1	U	94kV; 25uA	Original classification: Saguinus oedipus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1438	19800	1544	1	U	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1439	34572	1544	1	U	94kV; 25uA	Original classification: Saguinus oedipus --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1440	19793	1544	1	U	94kV; 25uA	Original classification: Saguinus oedipus geoffroyi	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1442	32163	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1443	30578	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1444	30580	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1445	32164	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1446	32165	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1447	30582	1511	1	U	94kV; 25uA	Original classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1476	5149	1625	1	U	130kV; 15uA	Original classification: Alouatta palliata --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1477	7316	1625	1	U	130kV; 15uA	Original classification: Alouatta palliata palliata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1478	7315	1625	1	U	?	Not included in the original spreadsheet\n\nOriginal classification: Alouatta palliata palliata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1484	5340	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi Kuhl	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1485	34320	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1486	5335	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi Kuhl	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1487	5338	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi Kuhl	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1465	30439	1617	1	U	130kV; 15uA	Original classification: Alouatta belzebul --\nOriginal sex: F (check)	2012-02-18	2012-04-19	\N	\N	\N	\N	\N	\N	\N	\N	f
1448	30579	1511	1	U	94kV; 25uA	M1 missing; M2 used for aligning lateral x-ray\n\nOriginal classification: Callithrix argentata argentata	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1488	5339	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi Kuhl	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1489	5349	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi Kuhl	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1490	5145	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi ?	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
1491	10138	1638	1	U	130kV; 15uA	Original classification: Ateles geoffroyi --	2012-02-18	2012-02-18	\N	\N	\N	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: radioapp_taxon; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY radioapp_taxon (id, parent_id, level, name, common_name, description) FROM stdin;
1501	\N	0	Animalia	\N	\N
1502	1501	1	Chordata	\N	\N
1503	1502	2	Mammalia	\N	\N
1504	1503	3	Primates	\N	\N
1505	1504	4		\N	\N
1506	1505	5	Cebidae	\N	\N
1507	1506	6	Callitrichinae	\N	\N
1508	1507	7	Callimico	\N	\N
1509	1508	8	goeldii	\N	\N
1510	1507	7	Callithrix	\N	\N
1511	1510	8	argentata	\N	\N
1512	1510	8	humeralifera	\N	\N
1513	1510	8	jacchus	\N	\N
1514	1510	8	penicillata	\N	\N
1515	1510	8	pygmaea	\N	\N
1516	1515	9	pygmaea	\N	\N
1517	1515	9	niveiventris	\N	\N
1518	1507	7	Leontopithecus	\N	\N
1519	1518	8	chrysomelas	\N	\N
1520	1518	8	rosalia	\N	\N
1521	1507	7	Saguinus	\N	\N
1522	1521	8	fuscicollis	\N	\N
1523	1522	9	fuscicollis	\N	\N
1524	1522	9	cruzlimai	\N	\N
1525	1522	9	fuscus	\N	\N
1526	1522	9	illigeri	\N	\N
1527	1522	9	leucocenys	\N	\N
1528	1522	9	lagonotus	\N	\N
1529	1522	9	nigrifrons	\N	\N
1530	1522	9	primitivus	\N	\N
1531	1522	9	weddelli	\N	\N
1532	1521	8	geoffroyi	\N	\N
1533	1521	8	graellsi	\N	\N
1534	1521	8	leucopus	\N	\N
1535	1521	8	midas	\N	\N
1536	1521	8	labiatus	\N	\N
1537	1536	9	labiatus	\N	\N
1538	1536	9	ruflventer	\N	\N
1539	1536	9	thomasi	\N	\N
1540	1521	8	niger	\N	\N
1541	1521	8	nigricollis	\N	\N
1542	1541	9	nigricollis	\N	\N
1543	1541	9	hernandezi	\N	\N
1544	1521	8	oedipus	\N	\N
1545	1506	6	Cebinae	\N	\N
1546	1545	7	Cebus	\N	\N
1547	1546	8	albifrons	\N	\N
1548	1547	9	albifrons	\N	\N
1549	1547	9	aequatorialis	\N	\N
1550	1547	9	cuscinus	\N	\N
1551	1547	9	trinitatis	\N	\N
1552	1547	9	unicolor	\N	\N
1553	1547	9	versicolor	\N	\N
1554	1546	8	apella	\N	\N
1555	1554	9	apella	\N	\N
1556	1554	9	fatuelius	\N	\N
1557	1554	9	macrocephalus	\N	\N
1558	1554	9	peruanus	\N	\N
1559	1554	9	tocantinus	\N	\N
1560	1546	8	capucinus	\N	\N
1561	1546	8	libidinosus	\N	\N
1562	1561	9	libidinosus	\N	\N
1563	1561	9	pallidus	\N	\N
1564	1561	9	paraguayanus	\N	\N
1565	1561	9	juruanus	\N	\N
1566	1546	8	nigritus	\N	\N
1567	1566	9	nigritus	\N	\N
1568	1566	9	cucllatus	\N	\N
1569	1566	9	robustus	\N	\N
1570	1546	8	olivaceus	\N	\N
1571	1546	8	xanthosternos	\N	\N
1572	1506	6	Saimiriinae	\N	\N
1573	1572	7	Saimiri	\N	\N
1574	1573	8	boliviensis	\N	\N
1575	1574	9	boliviensis	\N	\N
1576	1574	9	peruviensis	\N	\N
1577	1573	8	oerstedii	\N	\N
1578	1577	9	oerstedii	\N	\N
1579	1577	9	citrinellus	\N	\N
1580	1573	8	sciureus	\N	\N
1581	1580	9	sciureus	\N	\N
1582	1580	9	albigena	\N	\N
1583	1580	9	cassiquiarensis	\N	\N
1584	1580	9	macrodon	\N	\N
1585	1505	5	Aotidae	\N	\N
1586	1585	6		\N	\N
1587	1586	7	Aotus	\N	\N
1588	1587	8	lemurinus	\N	\N
1589	1588	9	lemurinus	\N	\N
1590	1588	9	brumbacki	\N	\N
1591	1588	9	griseimembra	\N	\N
1592	1588	9	zonalis	\N	\N
1593	1587	8	nigriceps	\N	\N
1594	1587	8	trivirgatus	\N	\N
1595	1505	5	Pithecidae	\N	\N
1596	1595	6	Callicebinae	\N	\N
1597	1596	7	Callicebus	\N	\N
1598	1597	8	moloch	\N	\N
1599	1597	8	ornatus	\N	\N
1600	1597	8	pallescens	\N	\N
1601	1597	8	torquatus	\N	\N
1602	1595	6	Pitheciinae	\N	\N
1603	1602	7	Cacajao	\N	\N
1604	1603	8	melanocephalus	\N	\N
1605	1602	7	Chiropotes	\N	\N
1606	1605	8	satanas	\N	\N
1607	1602	7	Pithecia	\N	\N
1608	1607	8	monachus	\N	\N
1609	1608	9	monachus	\N	\N
1610	1608	9	milleri	\N	\N
1611	1607	8	pithecia	\N	\N
1612	1611	9	pithecia	\N	\N
1613	1611	9	chrysocephalia	\N	\N
1614	1505	5	Atelidae	\N	\N
1615	1614	6	Alouattinae	\N	\N
1616	1615	7	Alouatta	\N	\N
1617	1616	8	belzebul	\N	\N
1618	1616	8	caraya	\N	\N
1619	1616	8	colibensis	\N	\N
1620	1619	9	coibensis	\N	\N
1621	1619	9	trabeata	\N	\N
1622	1616	8	guariba	\N	\N
1623	1622	9	guariba	\N	\N
1624	1622	9	clamitans	\N	\N
1625	1616	8	palliata	\N	\N
1626	1616	8	pigra	\N	\N
1627	1616	8	seniculus	\N	\N
1628	1627	9	seniculus	\N	\N
1629	1627	9	arctoidea	\N	\N
1630	1627	9	juara	\N	\N
1631	1614	6	Atelinae	\N	\N
1632	1631	7	Ateles	\N	\N
1633	1632	8	belzebuth	\N	\N
1634	1632	8	chamek	\N	\N
1635	1632	8	fusciceps	\N	\N
1636	1635	9	fusciceps	\N	\N
1637	1635	9	rufiventris	\N	\N
1638	1632	8	geoffroyi	\N	\N
1639	1638	9	geoffroyi	\N	\N
1640	1638	9	grisescens	\N	\N
1641	1638	9	ornatus	\N	\N
1642	1638	9	vellerosus	\N	\N
1643	1638	9	yucatanensis	\N	\N
1644	1632	8	hybridus	\N	\N
1645	1632	8	paniscus	\N	\N
1646	1631	7	Brachyteles	\N	\N
1647	1646	8	arachnoides	\N	\N
1648	1631	7	Lagothrix	\N	\N
1649	1648	8	lagotricha	\N	\N
1650	1505	5	Cercopithecidae	\N	\N
1651	1650	6	Cercopithecinae	\N	\N
1652	1651	7	Cercocebus	\N	\N
1653	1652	8	agilis	\N	\N
1654	1652	8	atys	\N	\N
1655	1654	9	atys	\N	\N
1656	1654	9	lunulatus	\N	\N
1657	1652	8	galeritus	\N	\N
1658	1652	8	torquatus	\N	\N
1659	1651	7	Cercopithecus	\N	\N
1660	1659	8	albogularis	\N	\N
1661	1660	9	albogularis	\N	\N
1662	1660	9	alotorquatus	\N	\N
1663	1660	9	erytharchus	\N	\N
1664	1660	9	francescae	\N	\N
1665	1660	9	kibonotensis	\N	\N
1666	1660	9	kolbi	\N	\N
1667	1660	9	labiatus	\N	\N
1668	1660	9	moloneyi	\N	\N
1669	1660	9	monoides	\N	\N
1670	1660	9	phylax	\N	\N
1671	1660	9	schwarzi	\N	\N
1672	1660	9	zammaranoi	\N	\N
1673	1659	8	ascanius	\N	\N
1674	1673	9	ascanius	\N	\N
1675	1673	9	atrinasus	\N	\N
1676	1673	9	katangae	\N	\N
1677	1673	9	schmidt	\N	\N
1678	1673	9	whitesidei	\N	\N
1679	1659	8	cephus	\N	\N
1680	1679	9	cephus	\N	\N
1681	1679	9	cephoides	\N	\N
1682	1679	9	ngottoensis	\N	\N
1683	1659	8	diana	\N	\N
1684	1659	8	lowei	\N	\N
1685	1659	8	mitis	\N	\N
1686	1685	9	mitis	\N	\N
1687	1685	9	boutourlinii	\N	\N
1688	1685	9	elgonis	\N	\N
1689	1685	9	heymansi	\N	\N
1690	1685	9	opisthostictus	\N	\N
1691	1685	9	stuhlmanni	\N	\N
1692	1659	8	mona	\N	\N
1693	1659	8	neglectus	\N	\N
1694	1659	8	nictitans	\N	\N
1695	1694	9	nictitans	\N	\N
1696	1694	9	martini	\N	\N
1697	1659	8	petaurista	\N	\N
1698	1697	9	petaurista	\N	\N
1699	1697	9	buettikoferi	\N	\N
1700	1659	8	pogonias	\N	\N
1701	1700	9	pogonias	\N	\N
1702	1700	9	grayi	\N	\N
1703	1700	9	nigripes	\N	\N
1704	1700	9	schwarzianus	\N	\N
1705	1651	7	Chlorocebus	\N	\N
1706	1705	8	aethiops	\N	\N
1707	1705	8	pygerythrus	\N	\N
1708	1707	9	pygerythrus	\N	\N
1709	1707	9	excubutor	\N	\N
1710	1707	9	hilgerti	\N	\N
1711	1707	9	nesiotes	\N	\N
1712	1707	9	nifoviridis	\N	\N
1713	1705	8	sabaeus	\N	\N
1714	1651	7	Erythrocebus	\N	\N
1715	1714	8	patas	\N	\N
1716	1651	7	Lophocebus	\N	\N
1717	1716	8	albigena	\N	\N
1718	1717	9	albigena	\N	\N
1719	1717	9	johnstoni	\N	\N
1720	1717	9	osmani	\N	\N
1721	1651	7	Macaca	\N	\N
1722	1721	8	arctoides	\N	\N
1723	1721	8	assamensis	\N	\N
1724	1723	9	assamensis	\N	\N
1725	1723	9	pelops	\N	\N
1726	1721	8	cyclopis	\N	\N
1727	1721	8	fascicularis	\N	\N
1728	1727	9	fascicularis	\N	\N
1729	1727	9	atriceps	\N	\N
1730	1727	9	aureus	\N	\N
1731	1727	9	condorensis	\N	\N
1732	1727	9	fuscus	\N	\N
1733	1727	9	karimondjawae	\N	\N
1734	1727	9	lasiae	\N	\N
1735	1650	6	Colobinae	\N	\N
1736	1735	7	Colobus	\N	\N
1737	1736	8	guereza	\N	\N
1738	1737	9	philippensis	\N	\N
1739	1727	9	tua	\N	\N
1740	1727	9	umbrosus	\N	\N
1741	1721	8	fuscata	\N	\N
1742	1741	9	fuscata	\N	\N
1743	1741	9	yakui	\N	\N
1744	1721	8	hecki	\N	\N
1745	1721	8	leonina	\N	\N
1746	1721	8	mulatta	\N	\N
1747	1721	8	nemestrina	\N	\N
1748	1721	8	nigra	\N	\N
1749	1721	8	sinica	\N	\N
1750	1749	9	sinica	\N	\N
1751	1749	9	aurifrons	\N	\N
1752	1721	8	sylvanus	\N	\N
1753	1721	8	thibetana	\N	\N
1754	1753	9	thibetana	\N	\N
1755	1753	9	esau	\N	\N
1756	1753	9	guiahouensis	\N	\N
1757	1753	9	huangshanensis	\N	\N
1758	1721	8	tonkeana	\N	\N
1759	1651	7	Mandrillus	\N	\N
1760	1759	8	leucophaeus	\N	\N
1761	1760	9	leucophaeus	\N	\N
1762	1760	9	poensis	\N	\N
1763	1759	8	sphinx	\N	\N
1764	1651	7	Miopithecus	\N	\N
1765	1764	8	talapoin	\N	\N
1766	1651	7	Papio	\N	\N
1767	1766	8	anubis	\N	\N
1768	1766	8	cynocephalus	\N	\N
1769	1768	9	cynocephalus	\N	\N
1770	1768	9	ibeanus	\N	\N
1771	1768	9	kindae	\N	\N
1772	1766	8	hamadryas	\N	\N
1773	1766	8	papio	\N	\N
1774	1766	8	ursinus	\N	\N
1775	1774	9	ursinus	\N	\N
1776	1774	9	griseipes	\N	\N
1777	1774	9	ruacana	\N	\N
1778	1651	7	Theropithecus	\N	\N
1779	1778	8	gelada	\N	\N
1780	1779	9	gelada	\N	\N
1781	1779	9	obscurus	\N	\N
1782	1736	8	angolensis	\N	\N
1783	1782	9	angolensis	\N	\N
1784	1782	9	cordieri	\N	\N
1785	1782	9	cottoni	\N	\N
1786	1782	9	palliates	\N	\N
1787	1782	9	prigoginei	\N	\N
1788	1782	9	ruwenzorii	\N	\N
1789	1737	9	guereza	\N	\N
1790	1737	9	caudatus	\N	\N
1791	1737	9	dodingae	\N	\N
1792	1737	9	kikuyuensis	\N	\N
1793	1737	9	matschiei	\N	\N
1794	1737	9	occidentalis	\N	\N
1795	1737	9	percivali	\N	\N
1796	1736	8	polykomos	\N	\N
1797	1735	7	Nasalis	\N	\N
1798	1797	8	larvatus	\N	\N
1799	1735	7	Piliocolobus	\N	\N
1800	1799	8	badius	\N	\N
1801	1800	9	badius	\N	\N
1802	1800	9	temminckii	\N	\N
1803	1800	9	waldronae	\N	\N
1804	1735	7	Presbytis	\N	\N
1805	1804	8	chrysomelas	\N	\N
1806	1805	9	chrysomelas	\N	\N
1807	1805	9	cruciger	\N	\N
1808	1804	8	femoralis	\N	\N
1809	1808	9	femoralis	\N	\N
1810	1808	9	percura	\N	\N
1811	1808	9	robinsoni	\N	\N
1812	1804	8	frontata	\N	\N
1813	1804	8	hosei	\N	\N
1814	1813	9	hosei	\N	\N
1815	1813	9	canicrus	\N	\N
1816	1813	9	everetti	\N	\N
1817	1813	9	sabana	\N	\N
1818	1804	8	melalophos	\N	\N
1819	1818	9	melalophos	\N	\N
1820	1818	9	bicolor	\N	\N
1821	1818	9	mitrata	\N	\N
1822	1818	9	sumatranus	\N	\N
1823	1804	8	potenziani	\N	\N
1824	1823	9	potenziani	\N	\N
1825	1823	9	siberu	\N	\N
1826	1804	8	rubicunda	\N	\N
1827	1826	9	rubicunda	\N	\N
1828	1826	9	carimatae	\N	\N
1829	1826	9	chrysea	\N	\N
1830	1826	9	ignita	\N	\N
1831	1826	9	rubida	\N	\N
1832	1804	8	siamensis	\N	\N
1833	1832	9	siamensis	\N	\N
1834	1832	9	cana	\N	\N
1835	1832	9	paenulata	\N	\N
1836	1832	9	rhionis	\N	\N
1837	1804	8	thomasi	\N	\N
1838	1735	7	Procolobus	\N	\N
1839	1838	8	verus	\N	\N
1840	1735	7	Pygathrix	\N	\N
1841	1840	8	nemaeus	\N	\N
1842	1840	8	nigripes	\N	\N
1843	1735	7	Rhinopithecus	\N	\N
1844	1843	8	roxellana	\N	\N
1845	1844	9	roxellana	\N	\N
1846	1844	9	hubeiensis	\N	\N
1847	1844	9	qinlingensis	\N	\N
1848	1735	7	Semnopithecus	\N	\N
1849	1848	8	priam	\N	\N
1850	1848	8	schistaceus	\N	\N
1851	1735	7	Simias	\N	\N
1852	1851	8	concolor	\N	\N
1853	1735	7	Trachypithecus	\N	\N
1854	1853	8	auratus	\N	\N
1855	1854	9	auratus	\N	\N
1856	1854	9	mauritius	\N	\N
1857	1853	8	cristatus	\N	\N
1858	1857	9	cristatus	\N	\N
1859	1857	9	vigilans	\N	\N
1860	1853	8	phayrei	\N	\N
1861	1860	9	phayrei	\N	\N
1862	1860	9	crepuscula	\N	\N
1863	1860	9	shanicus	\N	\N
1864	1853	8	vetulus	\N	\N
1865	1864	9	vetulus	\N	\N
1866	1864	9	monticola	\N	\N
1867	1864	9	nestor	\N	\N
1868	1864	9	philbricki	\N	\N
1869	1505	5	Hylobatidae	\N	\N
1872	1871	8	agilis	\N	\N
1873	1871	8	albibarbis	\N	\N
1874	1871	8	klossii	\N	\N
1875	1871	8	lar	\N	\N
1876	1875	9	lar	\N	\N
1877	1875	9	carpenteri	\N	\N
1878	1875	9	entelloides	\N	\N
1879	1875	9	vestitus	\N	\N
1880	1875	9	yunnanensis	\N	\N
1881	1871	8	muelleri	\N	\N
1882	1881	9	muelleri	\N	\N
1883	1881	9	abbotti	\N	\N
1884	1881	9	funereus	\N	\N
1885	1871	8	pileatus	\N	\N
1887	1886	8	concolor	\N	\N
1888	1887	9	concolor	\N	\N
1889	1887	9	furvogaster	\N	\N
1890	1887	9	jingdongensis	\N	\N
1891	1887	9	lu	\N	\N
1892	1887	9	nasutus	\N	\N
1893	1886	8	gabriellae	\N	\N
1894	1886	8	leucogenys	\N	\N
1896	1895	8	syndactylus	\N	\N
1897	1505	5	Hominidae	\N	\N
1900	1899	8	beringei	\N	\N
1901	1900	9	beringei	\N	\N
1902	1900	9	graueri	\N	\N
1903	1899	8	gorilla	\N	\N
1904	1903	9	gorilla	\N	\N
1905	1903	9	diehli	\N	\N
1907	1906	8	sapiens	\N	\N
1909	1908	8	paniscus	\N	\N
1910	1908	8	troglodytes	\N	\N
1911	1910	9	troglodytes	\N	\N
1912	1910	9	schweinfurthii	\N	\N
1913	1910	9	vellerosus	\N	\N
1914	1910	9	verus	\N	\N
1916	1915	8	abelii	\N	\N
1917	1915	8	pygmaeus	\N	\N
1918	1917	9	pygmaeus	\N	\N
1919	1917	9	morio	\N	\N
1920	1917	9	wurmbii	\N	\N
1871	1586	7	Hylobates	\N	\N
1886	1586	7	Nomascus	\N	\N
1895	1586	7	Symphalangus	\N	\N
1899	1586	7	Gorilla	\N	\N
1906	1586	7	Homo	\N	\N
1908	1586	7	Pan	\N	\N
1915	1586	7	Pongo	\N	\N
1921	1510	8	chrysoleuca	\N	\N
1922	1510	8	aurita	\N	\N
1923	1764	8	ogouensis	\N	\N
1924	1727	9	fusca	\N	\N
1925	1727	9	aurea	\N	\N
1926	1782	9	caudatus	\N	\N
1927	1782	9	palliatus	\N	\N
1928	1782	9	dodingae	\N	\N
1929	1660	9	erythrarchus	\N	\N
1930	1679	9	cephodes	\N	\N
1931	1673	9	schmidti	\N	\N
1932	1521	8	mystax	\N	\N
1933	1606	9	sagulatus	\N	\N
1934	1606	9	chiropotes	\N	\N
1935	1616	8	coibensis	\N	\N
1936	1935	9	coibensis	\N	\N
1937	1932	9	mystax	\N	\N
1939	1522	9	avilapiresi	\N	\N
1940	1512	9	humeralifera	\N	\N
1941	1513	9	jacchus	\N	\N
1942	1513	9	geoffroyi	\N	\N
1943	1513	9	jordani	\N	\N
1944	1520	9	rosalia	\N	\N
1938	1522	9	leucogenys	\N	\N
1945	1818	9	sumatrana	\N	\N
1946	1849	9	thersites	\N	\N
1947	1850	9	schistaceus	\N	\N
1948	1860	9	crepusculus	\N	\N
\.


--
-- Data for Name: south_migrationhistory; Type: TABLE DATA; Schema: public; Owner: radiograph
--

COPY south_migrationhistory (id, app_name, migration, applied) FROM stdin;
1	radioapp	0001_initial	2012-04-17 03:50:41.253087+00
2	radioapp	0002_auto__add_field_specimen_skull_length__add_field_specimen_cranial_widt	2012-04-17 03:54:11.209704+00
3	radioapp	0003_auto__add_field_image_deleted__add_field_specimen_deleted	2012-04-28 23:42:10.865855+00
\.


--
-- Name: auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions_group_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_key UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_message_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_message
    ADD CONSTRAINT auth_message_pkey PRIMARY KEY (id);


--
-- Name: auth_permission_content_type_id_codename_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_key UNIQUE (content_type_id, codename);


--
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_user_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_key UNIQUE (user_id, group_id);


--
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_user_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id);


--
-- Name: auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type_app_label_model_key; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_key UNIQUE (app_label, model);


--
-- Name: django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: radioapp_image_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY radioapp_image
    ADD CONSTRAINT radioapp_image_pkey PRIMARY KEY (id);


--
-- Name: radioapp_institution_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY radioapp_institution
    ADD CONSTRAINT radioapp_institution_pkey PRIMARY KEY (id);


--
-- Name: radioapp_specimen_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY radioapp_specimen
    ADD CONSTRAINT radioapp_specimen_pkey PRIMARY KEY (id);


--
-- Name: radioapp_taxon_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY radioapp_taxon
    ADD CONSTRAINT radioapp_taxon_pkey PRIMARY KEY (id);


--
-- Name: south_migrationhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: radiograph; Tablespace: 
--

ALTER TABLE ONLY south_migrationhistory
    ADD CONSTRAINT south_migrationhistory_pkey PRIMARY KEY (id);


--
-- Name: auth_group_permissions_group_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_group_permissions_group_id ON auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_group_permissions_permission_id ON auth_group_permissions USING btree (permission_id);


--
-- Name: auth_message_user_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_message_user_id ON auth_message USING btree (user_id);


--
-- Name: auth_permission_content_type_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_permission_content_type_id ON auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_user_groups_group_id ON auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_user_groups_user_id ON auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_user_user_permissions_permission_id ON auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX auth_user_user_permissions_user_id ON auth_user_user_permissions USING btree (user_id);


--
-- Name: django_admin_log_content_type_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX django_admin_log_content_type_id ON django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX django_admin_log_user_id ON django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX django_session_expire_date ON django_session USING btree (expire_date);


--
-- Name: radioapp_image_specimen_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_image_specimen_id ON radioapp_image USING btree (specimen_id);


--
-- Name: radioapp_specimen_created_by_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_specimen_created_by_id ON radioapp_specimen USING btree (created_by_id);


--
-- Name: radioapp_specimen_institution_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_specimen_institution_id ON radioapp_specimen USING btree (institution_id);


--
-- Name: radioapp_specimen_last_modified_by_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_specimen_last_modified_by_id ON radioapp_specimen USING btree (last_modified_by_id);


--
-- Name: radioapp_specimen_taxon_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_specimen_taxon_id ON radioapp_specimen USING btree (taxon_id);


--
-- Name: radioapp_taxon_parent_id; Type: INDEX; Schema: public; Owner: radiograph; Tablespace: 
--

CREATE INDEX radioapp_taxon_parent_id ON radioapp_taxon USING btree (parent_id);


--
-- Name: auth_group_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_message_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_message
    ADD CONSTRAINT auth_message_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_type_id_refs_id_728de91f; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT content_type_id_refs_id_728de91f FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: created_by_id_refs_id_45ee7802; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_specimen
    ADD CONSTRAINT created_by_id_refs_id_45ee7802 FOREIGN KEY (created_by_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log_content_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_fkey FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: group_id_refs_id_3cea63fe; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT group_id_refs_id_3cea63fe FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: last_modified_by_id_refs_id_45ee7802; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_specimen
    ADD CONSTRAINT last_modified_by_id_refs_id_45ee7802 FOREIGN KEY (last_modified_by_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: parent_id_refs_id_22c748c3; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_taxon
    ADD CONSTRAINT parent_id_refs_id_22c748c3 FOREIGN KEY (parent_id) REFERENCES radioapp_taxon(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: radioapp_image_specimen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_image
    ADD CONSTRAINT radioapp_image_specimen_id_fkey FOREIGN KEY (specimen_id) REFERENCES radioapp_specimen(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: radioapp_specimen_institution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_specimen
    ADD CONSTRAINT radioapp_specimen_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES radioapp_institution(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: radioapp_specimen_taxon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY radioapp_specimen
    ADD CONSTRAINT radioapp_specimen_taxon_id_fkey FOREIGN KEY (taxon_id) REFERENCES radioapp_taxon(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_7ceef80f; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT user_id_refs_id_7ceef80f FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_dfbab7d; Type: FK CONSTRAINT; Schema: public; Owner: radiograph
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT user_id_refs_id_dfbab7d FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

