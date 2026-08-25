--
-- PostgreSQL database dump
--

\restrict hf1gFIXsNRgIamrGLfygjGrDvtkFnuIbLohkRMcI06vxTySIwSRN2caQ7u259qq

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg12+1)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: despair_tanka_db_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO despair_tanka_db_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: despair_tanka_db_user
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO despair_tanka_db_user;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: despair_tanka_db_user
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    author_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    error_message text,
    likes_count integer,
    tanka text,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


ALTER TABLE public.posts OWNER TO despair_tanka_db_user;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: despair_tanka_db_user
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.posts_id_seq OWNER TO despair_tanka_db_user;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: despair_tanka_db_user
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: despair_tanka_db_user
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO despair_tanka_db_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: despair_tanka_db_user
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying
);


ALTER TABLE public.users OWNER TO despair_tanka_db_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: despair_tanka_db_user
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO despair_tanka_db_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: despair_tanka_db_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: despair_tanka_db_user
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
schema_sha1	9b8b661edda011644e9027ca7ccc7e98bb2cb5dc	2026-08-11 06:15:44.603643	2026-08-11 06:15:44.603646
environment	development	2026-08-11 06:15:44.522633	2026-08-12 05:28:37.212374
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: despair_tanka_db_user
--

COPY public.posts (id, author_name, created_at, error_message, likes_count, tanka, updated_at, user_id) FROM stdin;
15	Tatooo	2026-08-11 12:43:55.490511	紙で指を切ってキーボード打ちにくいやん！	5	紙で切った 指の痛みよ じんじんと  \nキーボード叩く 指が震える  \nエラー出たよ うつむく心  \nもういやだな こんな日々よ  \nプログラムよりも 指が辛い	2026-08-11 12:43:55.490511	4
18	エラーの人	2026-08-11 15:39:35.757194	RoutingError	5	道を誤り ルーティングエラー 迷い込む  \nどこへ行くのか 誰も教えて  \n深夜のコードが 眠れぬままに  \nバグと格闘し 夢の中でも	2026-08-11 15:39:35.757194	5
1	テスト法師	2026-08-11 06:54:47.913218	AmbiguousGrantByEmailAddress\t	0	エラー出て　メールアドレスが　曖昧だと　何度も見ても　意味がわからぬ	2026-08-11 06:54:47.913218	\N
20		2026-08-12 05:20:47.750518	RequestTimeTooSkewed	1	\N	2026-08-12 05:20:47.750518	\N
19	もーいーぬ	2026-08-12 05:20:20.599235	RequestTimeTooSkewed	1	\N	2026-08-12 05:20:20.599235	\N
2		2026-08-11 06:57:42.191302	TypeError: Cannot read properties of undefined (reading 'foo')\n    at Object.<anonymous> (/Users/user/project/index.js:10:15)\n    at Module._compile (node:internal/modules/cjs/loader:1105:14)\n    ...\n	0	未定義  それが何かを  読み取れず  \nエラー文  目を凝らしても  わからない  \nデバッグ中  ふとした瞬間  笑えてくる  \n真剣さ  背中押されて  また挑む  \n前向きに  進む道なら  光見える	2026-08-11 06:57:42.191302	\N
3		2026-08-11 07:13:55.619748	エラーです	0	エラー出た  \n何もしていない  \n僕のせい？  \n静かな夜に  \n心がざわつく	2026-08-11 07:13:55.619748	\N
4	やっさん	2026-08-11 07:14:37.659897	私の人生がエラーです	0	私の人生がエラーです  \nコンパイルもせずに  \n進む道は暗く  \nバグの海に溺れ  \n涙のコード書く	2026-08-11 07:14:37.659897	\N
17		2026-08-11 15:33:50.563647	config/routes.rb:22:4: C: [Corrected] Layout/TrailingEmptyLines: Final newline missing.	15	最後の 行がないと 言われてる どうしても 直せぬまま	2026-08-11 15:33:50.563647	\N
16	あああ	2026-08-11 13:28:37.426408	エラー出たーーやったー	9	エラー出た  やったーと叫ぶ  駆け出しの  直すたび増える  罠にハマるよ	2026-08-11 13:28:37.426408	\N
5	テスト	2026-08-11 09:06:18.913322	申訳無（申し訳ございません）。ただいまシステム内部にて破滅的な例外（Uncaught RuntimeError）が発生し、処理を中断いたしました。エラーコード：0xDEADBEEF。スタックトレースの最下層において、未定義の nil オブジェクトに対するメソッド呼び出しが検出されました。入力された文字群が想定される最大長（255バイト）を大幅に超過しているか、または未知の特殊記号がパース処理を破壊した可能性が高く存じます。恐れ入りますが、トップページへ戻り、精神を落ち着かせた上で、もう一度最初からフォームの入力をやり直してくださいませ。	0	エラーだよ 申し訳ないが 何が悪い  \n無限ループで ひたすら考える  \nデバッグの夜	2026-08-11 09:06:18.913322	1
6	めたぴがわえだのすけ	2026-08-11 10:10:45.478109	Cannot connect to the Docker daemon	0	ダメだとね つながらぬままに うろたえる  \nDockerの海で ひとり漂う  \nバージョンの壁 乗り越えられず  \n指先震え もう一度挑む	2026-08-11 10:10:45.478109	\N
7	めたぴがわえだのすけ	2026-08-11 10:12:41.221147	404 Not Found	0	ページが見つからない 404  \n君を探しても どこにもいない  \nリンク切れたのか それとも夢か  \n朝のコーヒーと 一緒に消えた  \nエラーはいつも 僕の味方	2026-08-11 10:12:41.221147	\N
8	めたぴがわえだのすけ	2026-08-11 10:14:16.883391	Operating System Not Found	0	OS見つからず 途方に暮れ  \nコードの海に 埋もれてゆく  \n再起動して 夢見たけど  \nまた同じで 何度目だろう	2026-08-11 10:14:16.883391	\N
9		2026-08-11 10:54:00.182986	got status: 503 Service Unavailable. {"error":{"code":503,"message":"This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try again later.","status":"UNAVAILABLE"}}	0	エラー出て 503に泣く夜よ 高まる望み いつかは解決 夢は消えずに	2026-08-11 10:54:00.182986	\N
10		2026-08-11 10:56:35.919206	MissingReferenceException: The object of type 'DoorMarker' has been destroyed but you are still trying to access it. Your script should either check if it is null or you should not destroy the object. UnityEngine.Object+MarshalledUnityObject.TryThrowEditorNullExceptionObject (UnityEngine.Object unityObj, System.String parameterName) (at <987aa4221989419a947e2c4ff5d6829c>:0) UnityEngine.Bindings.ThrowHelper.ThrowNullReferenceException (System.Object obj) (at <987aa4221989419a947e2c4ff5d6829c>:0) UnityEngine.Component.get_transform () (at <987aa4221989419a947e2c4ff5d6829c>:0) World.FindNearbyDoorMarker (UnityEngine.Vector3 position) (at Assets/Scripts/World/World.cs:81) World.OnBlockChanged (UnityEngine.Vector3 position) (at Assets/Scripts/World/World.cs:51) PlayerController.HandleBlockInteraction () (at Assets/Scripts/Player/PlayerController.cs:124) PlayerController.Update () (at Assets/Scripts/Player/PlayerController.cs:157)	0	消えたドア 触れたらエラーの 冷たい手 まだ残る影に 何を求める	2026-08-11 10:56:35.919206	\N
11	Elu	2026-08-11 11:05:22.686829	400. That’s an error.\n\nThe server cannot process the request because it is malformed. It should not be retried. That’s all we know.	0	エラー出て 何が悪いのか 誰にもわからず 再試行するも ただの徒労よ	2026-08-11 11:05:22.686829	2
12		2026-08-11 11:15:50.857223	The name 'houses' does not exist in the current context	0	名前ない それは私の 夢の中  \nハウスを作るはずが どこへ消えた  \nエラーの海で 泳ぐは私  \n思い出させて よりそいの名を	2026-08-11 11:15:50.857223	\N
13		2026-08-11 12:02:15.650129	ぐええええ、なんてこったタイポミス	0	ぐええええ なんてこったと 笑う声  \n気づけばいつも タイポのせいだ  \nバグが出るたび 新たな悩み  \nああ、これまたか 先に進めず	2026-08-11 12:02:15.650129	\N
14	いさのすけ	2026-08-11 12:37:42.215232	Error response from daemon: No such container: bug_app-bug-app-1 テキストのコンテナ名書いたのに	0	コンテナが ないと告げられ 目が点に  \nテキスト合ってる？ もう一度確認  \n再起動して 夢の中に行く  \nバグとの戦い いつ終わるのか	2026-08-11 12:37:42.215232	\N
21		2026-08-12 05:41:45.424061	RequestTimeTooSkewed	0	\N	2026-08-12 05:41:45.424061	\N
22		2026-08-12 05:47:39.056852	UnresolvableGrantByEmailAddress	0	\N	2026-08-12 05:47:39.056852	\N
28	ai中毒	2026-08-12 08:29:23.84783	rate limit	2	かーの数え 限界越えても 何もできず 指先震えて 暗闇に消え	2026-08-12 08:29:23.84783	\N
23		2026-08-12 06:06:52.916322	UnresolvableGrantByEmailAddress	1	エラー吐き 詠めぬ短歌の 虚しさよ 深夜三時に 鳴り響くログ	2026-08-12 06:06:52.916322	\N
25		2026-08-12 06:33:01.129986	NoMethodError: undefined method `user' for nil:NilClass\n    from app/controllers/posts_controller.rb:23:in `create'	3	こわれたな あの時の夢が 消えてゆくよ ユーザーはどこか 未練を残し	2026-08-12 06:33:01.129986	1
24		2026-08-12 06:07:11.012013	UnresolvableGrantByEmailAddress	3	ビルド落ち ローカル動く 何故なんだ 本番環境 修羅の道なり	2026-08-12 06:07:11.012013	\N
43		2026-08-15 04:05:46.236507	AmbiguousGrantByEmailAddress	\N	迷い道 メールの影が 消えゆくぞ いつか助けて 夢も朽ち果て	2026-08-15 04:05:46.236507	\N
30		2026-08-12 12:49:21.534481	Exception in thread "main" java.lang.NullPointerException\n    at com.example.MyClass.doSomething(MyClass.java:15)\n    at com.example.Main.main(Main.java:8)\n	\N	意図せず 空の参照に 立ち尽くし 何もかもが消え 崩れ去る夢よ	2026-08-12 12:49:21.534481	\N
31		2026-08-12 12:52:37.878135	Assets\\Scripts\\World\\HouseDetector.cs(41,29): error CS0136: A local or parameter named 'checkPosition' cannot be declared in this scope because that name is used in an enclosing local scope to define a local or parameter\n	\N	名を重ね 解決の糸 見えぬまま 包まれた手が ただ彷徨うのみ	2026-08-12 12:52:37.878135	\N
32	ねこたけ	2026-08-13 06:05:57.360038	issueどんどん増えて辛い	1	問題増え 頭痛がして 夢見ても コードはまるで 悪夢の中に	2026-08-13 06:05:57.360038	\N
27		2026-08-12 07:09:48.478853	TypeError: Cannot read properties of undefined (reading 'foo')\n    at Object.<anonymous> (/Users/user/project/index.js:10:15)\n    at Module._compile (node:internal/modules/cjs/loader:1105:14)\n    at Module._extensions..js (node:internal/modules/cjs/loader:1159:10)\n    at Module.load (node:internal/modules/cjs/loader:981:32)\n    at Module._load (node:internal/modules/cjs/loader:822:12)\n    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:81:12)\n    at node:internal/main/run_main_module:23:47\n	2	読み取れぬ 不明なるものが 真っ暗な ファイルの中身に 私がいるよ	2026-08-12 07:09:48.478853	\N
26	ねこさん	2026-08-12 06:48:33.789601	WARN[0000] /home/yuukr/v4_rails_advanced_first_part/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion \nDEPRECATION WARNING: Using legacy connection handling is deprecated. Please set\n`legacy_connection_handling` to `false` in your application.\n\nThe new connection handling does not support `connection_handlers`\ngetter and setter.\n\nRead more about how to migrate at: https://guides.rubyonrails.org/active_record_multiple_databases.html#migrate-to-the-new-connection-handling\n (called from <top (required)> at /v3_advanced_rails/config/environment.rb:5)\nDEPRECATION WARNING: Using legacy connection handling is deprecated. Please set\n`legacy_connection_handling` to `false` in your application.\n\nThe new connection handling does not support `connection_handlers`\ngetter and setter.\n\nRead more about how to migrate at: https://guides.rubyonrails.org/active_record_multiple_databases.html#migrate-to-the-new-connection-handling\n (called from <top (required)> at /v3_advanced_rails/config/environment.rb:5)\nDEPRECATION WARNING: 'include Pundit' is deprecated. Please use 'include Pundit::Authorization' instead.\n (called from include at /v3_advanced_rails/app/controllers/application_controller.rb:2)\n\n== Seed from /v3_advanced_rails/db/fixtures/test/sites.rb\n - Site {:id=>1, :name=>"Blog", :subtitle=>"Very awesome!"}\n.\n\nFinished in 9.99 seconds (files took 20.29 seconds to load)\n1 example, 0 failures	3	古き良き つながり求め エラー吐く 過去の影響で 先が見えぬ	2026-08-12 06:48:33.789601	\N
49	アレクサ	2026-08-16 13:35:44.87687	接続先が見つかりません	2	途切れた線 迷路の中で 探し続け 誰もいない夜 声を失って	2026-08-16 13:35:44.87687	\N
40		2026-08-13 13:04:06.600688	test\n	1	テストの行 無限ループに はまっている 時間だけが過ぎ 心も崩れ	2026-08-13 13:04:06.600688	\N
39	みたらし	2026-08-13 11:55:36.470802	ねこーーーー\nエラーわかんないよ もう帰ってええか？ええよな？	1	ねこがいない エラーの海に 漂ってる 帰りたくても 出口見つからぬ	2026-08-13 11:55:36.470802	\N
38	みたらし	2026-08-13 11:54:32.651215	ねこさわりたい\nエラーわかんないよ\nねこさわりたい	2	ねこの夢 さわることすら できないな エラーが私を また閉じ込める	2026-08-13 11:54:32.651215	\N
44		2026-08-15 06:00:13.421975	てんとう虫	1	てんとう虫 画面に貼りつく 小さな影 どこから来たのか 闇に消えゆく	2026-08-15 06:00:13.421975	\N
42		2026-08-14 05:50:45.32792	Fatal error: Uncaught Error: Call to undefined function my_undefined_function() in /var/www/html/index.php:5\nStack trace:\n#0 {main}\n  thrown in /var/www/html/index.php on line 5	17	未定義の 関数呼び出す 見えぬ先 無限ループに 閉じ込められ	2026-08-14 05:50:45.32792	\N
37	ねこまにあ	2026-08-13 11:51:47.25225	エラーよく分からない\n蝉うるさい\n唐揚げにしたるぞコラ	1	エラー舞う 蝉の声さえ 響く夜に から揚げ作る 心折れそう	2026-08-13 11:51:47.25225	\N
34	Elu	2026-08-13 09:52:24.739652	No method Errorだよおおお	1	ふたを開けて 出てくるのは 夢の欠片 空っぽコードに 涙も一緒	2026-08-13 09:52:24.739652	2
36	ねこまにあ	2026-08-13 11:50:43.650489	出づるわざわい\n心惑いて\n蝉の声\n黙れお前を\n唐揚げにせん	1	とどまるな 心かき乱し 蝉の声よ 鳴き疲れてゆけ 夜を越せぬか	2026-08-13 11:50:43.650489	\N
46		2026-08-16 09:11:51.582684	改善しても新たなエラーで立ち尽くす	1	手を加え 今度はまた 行き止まり 海の底に 沈む思いよ	2026-08-16 09:11:51.582684	\N
52	ナナ	2026-08-17 03:37:38.603204	同じコードでも、ブラウザOS違いで動かない。	1	異なる空 動かぬコード 同じはず 全ての環境 違う影に	2026-08-17 03:37:38.603204	\N
41	まど納言	2026-08-14 01:41:26.535296	エラー出ても何のエラーか分からないのが辛い\n	16	見えぬ声 エラーの海で さまよう僕 真っ暗な画面 ただ待つ時間	2026-08-14 01:41:26.535296	6
48	愛しさと切なさと心強さとめたぴがわりゅうのすけ	2026-08-16 13:33:52.951497	fatal: not a git repository	1	暗闇で うろうろしてる 迷い道 手探りのまま 終わらぬ夜よ	2026-08-16 13:33:52.951497	\N
51		2026-08-16 15:12:26.081189	404	1	さまよえど 行き着く先は 青い画面 誰も知らない 孤独な夜よ	2026-08-16 15:12:26.081189	\N
50	さかさかさ	2026-08-16 15:03:01.411594	もーさんの\n怒りがこもった\nこのアプリ\nUI部分に\nうらみちらほら\n	2	もーさんの 怒りがこもった このアプリ UI部分に うらみちらほら	2026-08-16 15:03:01.411594	\N
47	ガッ	2026-08-16 13:12:40.943575	NullPointerException	3	ぬるぽに ひかりもなき はさまれし あいだの空に わたしの夢よ	2026-08-16 13:12:40.943575	\N
33		2026-08-13 07:39:13.649683	Fatal error: Uncaught Error: Call to undefined function my_undefined_function() in /var/www/html/index.php:5\nStack trace:\n#0 {main}\n  thrown in /var/www/html/index.php on line 5\n	1	深い闇に 消えた関数よ 呼んでも無駄 コードの迷路で 彷徨うばかり	2026-08-13 07:39:13.649683	\N
35		2026-08-13 09:52:51.587789	404	1	こいしいな みつからないよ せかいのど すがたをけせば はてしなき道	2026-08-13 09:52:51.587789	\N
29		2026-08-12 12:12:24.846274	エラーは出ていないが、意図通りに動いていない	29	動かぬまま 闇に佇む コーディングが 夢から覚めず 漂う静寂	2026-08-12 12:12:24.846274	\N
45		2026-08-15 07:02:36.854588	ArgumentError in MultiplayerGamesController#rematch\nWhen assigning attributes, you must pass a hash as an argument, NilClass passed.	2	ぬかるみで 無限の引数 エラー響く 絶望の中 立ち尽くすよ	2026-08-15 07:02:36.854588	\N
66	 	2026-08-19 09:52:33.575971	さ	\N	凍えている 画面の隅で 青い文字 無限ループに 心折れそう	2026-08-19 09:52:33.575971	\N
54	迷えるエンジニア	2026-08-17 13:31:37.346455	404 not found	2	見えぬ道 探して歩く 消えたもの 行き場さえも 迷路に入り	2026-08-17 13:31:37.346455	\N
56	フジさん	2026-08-18 01:05:30.020794	https://despair-tanka.onrender.com/omikuji	\N	リンク切れ 闇に消えた 期待の星 戻らぬ道を 彷徨うだけか	2026-08-18 01:05:30.020794	\N
57	フジさん	2026-08-18 01:06:13.591509	ActionController::RoutingError	1	道を外れ 誰も知らぬ 迷いの中 呼んでもこない それでも進む	2026-08-18 01:06:13.591509	\N
58	園児にあ	2026-08-18 06:18:13.013316	ActiveRecord::LockWaitTimeout	1	鍵がかかる ドアの向こうで 時は止まる 待ち続けても 夢の行方は	2026-08-18 06:18:13.013316	\N
55	虚無顔	2026-08-17 14:51:49.056916	エラー画面が出ない。だが実装はうまく行っていない。原因わからない。	1	エラー吐き 詠めぬ短歌の 虚しさよ 文字超えゆきて 涙こぼれる	2026-08-17 14:51:49.056916	\N
60		2026-08-19 02:51:49.735906	PreconditionFailed	\N	エラー吐き 詠めぬ短歌の 虚しさよ 文字超えゆきて 涙こぼれる	2026-08-19 02:51:49.735906	\N
61		2026-08-19 02:52:06.943509	PreconditionFailed	\N	たしかなもの 前提崩れて 夢の跡に 一つの条件 探す道もなし	2026-08-19 02:52:06.943509	\N
67	カンちゃん	2026-08-19 10:00:15.41582	勉強したことが身についてるか不安だよ〜〜	1	まなびの道 ゆらぐ自信に つまずきつつ 進むこの先も ああ不安だよ	2026-08-19 10:00:15.41582	\N
63	massan	2026-08-19 02:55:02.591526	NoMethoderror	1	手探りで 引数の名は どこにある 夜明け前にも 涙の雫	2026-08-19 02:55:02.591526	\N
62		2026-08-19 02:54:27.447043	見つからない、ころん。タイポはそのままにしちゃえ	1	打ちひしがれ 目の前にある ホームすらも 消えてしまった 文言無情よ	2026-08-19 02:54:27.447043	\N
59		2026-08-19 02:50:08.989615	ArgumentError\nMissing :controller key on routes definition, please check your routes.	2	ルーティング 欠けた鍵穴に 戸惑う指 迷路に迷い 行き場を失う	2026-08-19 02:50:08.989615	\N
64		2026-08-19 02:55:05.814948	タイポがタイポを呼び、さらにタイポ	1	間違いの 連鎖するよ 運命か 文字を追うに 終わらぬ夜	2026-08-19 02:55:05.814948	\N
65	古きエンジニア	2026-08-19 08:16:28.283947	Internal Server Error	\N	ああサーバー 何を言わんと 息も絶えず 夢の続きが 消えてしまう	2026-08-19 08:16:28.283947	\N
53	さぼてん	2026-08-17 11:21:00.737754	Started GET "/dashboard" for ::1 at 2026-08-10 07:32:28 +0900\nProcessing by DashboardController#index as HTML\nUser Load (0.5ms)  SELECT "users".\\* FROM "users" WHERE "users"."id" = 11 ORDER BY "users"."id" ASC LIMIT 1 /*action='index',application='FamilyApp',controller='dashboard'*/\nFamily Load (0.8ms)  SELECT "families".\\* FROM "families" INNER JOIN "family\\_members" ON "families"."id" = "family\\_members"."family\\_id" WHERE "family\\_members"."user\\_id" = 11 ORDER BY "families"."id" ASC LIMIT 1 /*action='index',application='FamilyApp',controller='dashboard'*/\n↳ app/controllers/dashboard\\_controller.rb:5\\:in `index'\n  Family Load (0.5ms)  SELECT "families".* FROM "families" WHERE "families"."id" = 7 LIMIT 1 /*action='index',application='FamilyApp',controller='dashboard'*/\n  ↳ app/controllers/dashboard_controller.rb:18:in `index'\nFamilyMember Load (0.3ms)  SELECT "family\\_members".\\* FROM "family\\_members" WHERE "family\\_members"."family\\_id" = 7 /*action='index',application='FamilyApp',controller='dashboard'*/\n↳ app/services/energy\\_manager.rb:97\\:in `flat_map'\n  TaskLog Load (0.2ms)  SELECT "task_logs".* FROM "task_logs" WHERE "task_logs"."family_member_id" IN (3, 11) /*action='index',application='FamilyApp',controller='dashboard'*/\n  ↳ app/services/energy_manager.rb:97:in `flat\\_map'\nCACHE FamilyMember Load (0.0ms)  SELECT "family\\_members".\\* FROM "family\\_members" WHERE "family\\_members"."family\\_id" = 7\n↳ app/controllers/dashboard\\_controller.rb:44\\:in `each_with_index'\n  User Load (0.3ms)  SELECT "users".* FROM "users" WHERE "users"."id" IN (4, 11) /*action='index',application='FamilyApp',controller='dashboard'*/\n  ↳ app/controllers/dashboard_controller.rb:44:in `each\\_with\\_index'\nTaskLog Load (0.6ms)  SELECT "task\\_logs".\\* FROM "task\\_logs" WHERE "task\\_logs"."family\\_member\\_id" = 3 ORDER BY "task\\_logs"."created\\_at" DESC LIMIT 1 /*action='index',application='FamilyApp',controller='dashboard'*/\n↳ app/controllers/dashboard\\_controller.rb:45\\:in `block in index'\n  TaskLog Load (0.4ms)  SELECT "task_logs".* FROM "task_logs" WHERE "task_logs"."family_member_id" = 11 ORDER BY "task_logs"."created_at" DESC LIMIT 1 /*action='index',application='FamilyApp',controller='dashboard'*/\n  ↳ app/controllers/dashboard_controller.rb:45:in `block in index'\nRendering layout layouts/application.html.erb\nRendering dashboard/index.html.erb within layouts/application\nRendered dashboard/index.html.erb within layouts/application (Duration: 0.4ms | GC: 0.0ms)\nRendered layout layouts/application.html.erb (Duration: 1.4ms | GC: 0.0ms)\nCompleted 200 OK in 28ms (Views: 1.8ms | ActiveRecord: 3.4ms (9 queries, 1 cached) | GC: 0.0ms) 	2	まぼろしの ファミリーの声 消えたログ 心は揺れる また始まるよ	2026-08-17 11:21:00.737754	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: despair_tanka_db_user
--

COPY public.schema_migrations (version) FROM stdin;
20260811032455
20260811071440
20260811071447
20260811075952
20260811120000
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: despair_tanka_db_user
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at, name) FROM stdin;
1	gomafu00penguin@gmail.com	$2a$12$QncQO86oCfdLyUkdTx1p0etcuXePHigbP1p6NaRpzxDP5/9Uu6ntK	\N	\N	\N	2026-08-11 08:58:00.264595	2026-08-11 08:58:00.264595	\N
2	eriloach0339vialattea@gmail.com	$2a$12$t3VSB44aAfE74dYmuHVpnuIZVtOMSD8Fagiu3rfCiPQjWUcjWzxiW	\N	\N	\N	2026-08-11 11:01:25.423939	2026-08-11 11:01:25.423939	Elu
4	tanigaway.08@gmail.com	$2a$12$RZY/WhlfljhB/IpdnjvrTuDCwVlyqiWLIHpKB.QJyGL0fxVTb7wd2	\N	\N	\N	2026-08-11 12:42:37.151141	2026-08-11 12:42:37.151141	Tatooo
5	a@a.co.jp	$2a$12$2i6KmVQG6r7MERqkYSBK0uVS5ha7yfjJ9xQQ2h70kPJs/9e9ZgMGW	\N	\N	\N	2026-08-11 15:37:50.068357	2026-08-11 15:37:50.068357	エラーの人
6	maachame@gmail.com	$2a$12$pDYwoe5kjoL1hSssh2Ikaer0RzR2nbspszDTgNYgKs5aaJOq3saXy	\N	\N	\N	2026-08-12 11:33:59.785588	2026-08-12 11:33:59.785588	迷えるランテック生
7	hiroshi151506@gmail.com	$2a$12$5RuSxgSo551314e1VKZYuu3V8yAxwJclL3G9y6Q3CkxHAWHFMdmGi	\N	\N	\N	2026-08-12 14:00:57.387276	2026-08-12 14:00:57.387276	zaki
9	snrsanthi2@gmail.com	$2a$12$H8Qj3R.cNd5QAufnUpBlQughHGiozNUHxo2Cs8VaM16pD2uWASxr2	\N	\N	\N	2026-08-13 09:51:03.982951	2026-08-13 09:51:03.982951	
8	snrsanthi@gmail.com	$2a$12$dUlB/IF8djC4xv7xHcipreMr4fqB4EjRyQPjX5NACR/Fh5FFfkBuW	\N	\N	\N	2026-08-13 09:50:11.483876	2026-08-13 09:52:01.906998	そのらん
3	meshidm@gmail.com	$2a$12$u5If8z6Jz8QIeeey6jpWd.7jo/mOHFYV8ACtv13Fy1GE5sYpIWopm	6b4efaefd9cb034c92192385df9da346ae32871a910994527d63e20877da6c5d	2026-08-15 17:33:24.706476	\N	2026-08-11 11:47:18.276543	2026-08-15 17:33:24.708332	まなぴ
10	paperdju2@gmail.com	$2a$12$1zEVPCS3TzOyUDbFuONLou4hj7e/bqf4iDA7Xzk3bhdZ1rwZNR74W	\N	\N	\N	2026-08-16 13:30:02.005361	2026-08-16 13:30:02.005361	絶望のめたっぴ
11	hurutori.024@gmail.com	$2a$12$VgH.jXJF7fn9fDLrdfqz1Omzv4o6OjP5qowBKaiAoagYkNQE6pvti	\N	\N	\N	2026-08-16 14:52:49.519438	2026-08-16 14:52:49.519438	さか
12	yukidaaayo@gmail.com	$2a$12$ad9cm9cTlKKIehO9HKmN7.hQORkArGiGW5Ed4S06mp5VNS6vMb5DG	\N	\N	\N	2026-08-17 11:13:36.425586	2026-08-17 11:13:36.425586	さぼてん
13	dingu3284@gmail.com	$2a$12$rcgCHIu4g1ZSAfy6EdrnjuAJjGea0E4v.JS9q/x0baNzOfwIoX.Re	\N	\N	\N	2026-08-17 13:30:34.228173	2026-08-17 13:30:34.228173	でぃん
14	fuji@test	$2a$12$K2sJ51AkuDqJaL57Kt.kgO8LZZDd/N2wffuRq1B9yoricKVpZXbb2	\N	\N	\N	2026-08-18 00:04:44.893504	2026-08-18 00:04:44.893504	フジさん
15	sakiyama@runteq.co.jp	$2a$12$sKRlN4.gwKqdE6USPJHOn.gwJj7qpCM7fw.g8LZzdtnUbgkgmcFIK	\N	\N	\N	2026-08-19 02:53:44.726121	2026-08-19 02:53:44.726121	やにかわ
16	urano@runteq.co.jp	$2a$12$PYo8.w18mI5GePUf9AMe5eGFRdtFDiCKxkhaGikTthJElnTFPiSQG	\N	\N	\N	2026-08-19 02:54:14.124123	2026-08-19 02:54:14.124123	massan
17	shunplay1793@gmail.com	$2a$12$0JR/FeD5KnO.i4FN6.R4Ne7xTeQ7KlnHZu4zsLRwZE.jthOIOd0QG	\N	\N	\N	2026-08-19 09:56:31.212713	2026-08-19 09:56:31.212713	カンちゃん
\.


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: despair_tanka_db_user
--

SELECT pg_catalog.setval('public.posts_id_seq', 67, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: despair_tanka_db_user
--

SELECT pg_catalog.setval('public.users_id_seq', 17, true);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_posts_on_user_id; Type: INDEX; Schema: public; Owner: despair_tanka_db_user
--

CREATE INDEX index_posts_on_user_id ON public.posts USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: despair_tanka_db_user
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: despair_tanka_db_user
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: posts fk_rails_5b5ddfd518; Type: FK CONSTRAINT; Schema: public; Owner: despair_tanka_db_user
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_5b5ddfd518 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO despair_tanka_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO despair_tanka_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO despair_tanka_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO despair_tanka_db_user;


--
-- PostgreSQL database dump complete
--

\unrestrict hf1gFIXsNRgIamrGLfygjGrDvtkFnuIbLohkRMcI06vxTySIwSRN2caQ7u259qq

