#pragma once

enum {eMaxLevel = 150};

// ��ɫ�Ա�
enum ECharSex 
{
	eCS_NoSex,
	eCS_Male,
	eCS_Female,
};

enum ERace
{
	eRA_Human,
	eRA_Orc,
	eRA_Elf,
	ePC_Dwarf,
};

// ְҵ����
enum EClass
{
	eCL_NoneClass = 0,	//��ְҵ
	eCL_Warrior,		//��ʿ
	eCL_MagicWarrior,	//ħ��ʿ
	eCL_Paladin,		//��ʿ
	eCL_NatureElf,		//��ʦ
	eCL_EvilElf,		//аħ
	eCL_Priest,			//��ʦ
	eCL_DwarfPaladin,	//������ʿ
	eCL_ElfHunter,		//���鹭����
	eCL_OrcWarrior,		//����սʿ
	eCL_Npc,			//NPC
	eCL_Wizard,			//��ʦ
	eCL_Assassin,		//�̿�
	eCL_Warlock,		//а��ʦ	
	eCL_WarPriest,		//ս��  
	eCL_Archer,			//������
	eCL_Soldier,		//��սʿ
	eCL_Summoner,		//�ٻ�ʦ
	eCL_Beast,			//Ұ��
	eCL_Summon,			//�ٻ�����
	eCL_Lancer,			//������ʿ
	eCL_Knight,			//������ʿ
	eCL_NatureElement,	//��ȻԪ��
	eCL_EvilElement,	//����Ԫ��
	eCL_DestructionElement,	//�ƻ�Ԫ��
	eCL_001,
	eCL_002,
	eCL_003,
	eCL_004,
	eCL_005,
	eCL_006,
	eCL_007,
	eCL_008,
	eCL_009,
	eCL_010,
	eCL_011,
	eCL_012,
	eCL_013,
	eCL_014,	//38��Bossְҵ
	eCL_015,
	eCL_016,
	eCL_017,
	eCL_018,
	eCL_019,
	eCL_020,
	eCL_021,
	eCL_022,
	eCL_023,
	eCL_024,
	eCL_025,
	eCL_026,
	eCL_027,
	eCL_028,
	eCL_029,
	eCL_030,
	eCL_031,
	eCL_032,	//56��Bossְҵ
	eCL_033,
	eCL_034,
	eCL_035,
	eCL_036,
	eCL_037,	//61��Bossְҵ
	eCL_038,
	eCL_039,
	eCL_040,
	eCL_041,	//65��Bossְҵ
	eCL_042,	//66��Bossְҵ
	eCL_043,	//67��Bossְҵ
	eCL_044,
	eCL_045,
	eCL_046,
	eCL_047,
	eCL_048,
	eCL_049,
	eCL_050,
	eCL_051,
	eCL_052,
	eCL_053,
	eCL_054,
	eCL_055,
	eCL_056,
	eCL_057,
	eCL_058,
	eCL_059,
	eCL_060,
	eCL_061,
	eCL_062,
	eCL_063,
	eCL_064,
	eCL_065,
	eCL_066,
	eCL_067,
	eCL_068,
	eCL_069,
	eCL_070,
	eCL_071,
	eCL_072,
	eCL_073,
	eCL_074,
	eCL_075,
	eCL_076,
	eCL_077,
	eCL_078,
	eCL_079,
	eCL_080,
	eCL_081,
	eCL_082,
	eCL_083,
	eCL_084,
	eCL_085,
	eCL_086,
	eCL_087,
	eCL_088,
	eCL_089,
	eCL_090,
	eCL_091,
	eCL_092,
	eCL_093,
	eCL_094,
	eCL_095,
	eCL_096,
	eCL_097,
	eCL_098,
	eCL_099,
	eCL_100,
	eCL_101,
	eCL_102,
	eCL_103,
	eCL_104,
	eCL_105,
	eCL_106,
	eCL_107,
	eCL_108,
	eCL_109,
	eCL_110,
	eCL_111,
	eCL_112,
	eCL_113,
	eCL_114,
	eCL_115,
	eCL_116,
	eCL_117,
	eCL_118,
	eCL_119,
	eCL_120,
	eCL_121,
	eCL_122,
	eCL_123,
	eCL_124,
	eCL_125,
	eCL_126,
	eCL_127,
	eCL_128,
	eCL_129,
	eCL_130,
	eCL_131,
	eCL_132,
	eCL_133,
	eCL_134,
	eCL_135,
	eCL_136,
	eCL_137,
	eCL_138,
	eCL_139,
	eCL_140,
	eCL_141,
	eCL_142,
	eCL_143,
	eCL_144,
	eCL_145,
	eCL_146,
	eCL_147,
	eCL_148,
	eCL_149,
	eCL_150,
	eCL_151,
	eCL_152,
	eCL_153,
	eCL_154,
	eCL_155,
	eCL_156,
	eCL_157,
	eCL_158,
	eCL_159,
	eCL_160,
	eCL_161,
	eCL_162,
	eCL_163,
	eCL_164,
	eCL_165,
	eCL_166,
	eCL_167,
	eCL_168,
	eCL_169,
	eCL_170,
	eCL_171,
	eCL_172,
	eCL_173,
	eCL_174,
	eCL_175,
	eCL_176,
	eCL_177,
	eCL_178,
	eCL_179,
	eCL_180,
	eCL_181,
	eCL_182,
	eCL_183,
	eCL_184,
	eCL_185,
	eCL_186,
	eCL_187,
	eCL_188,
	eCL_189,
	eCL_190,
	eCL_191,
	eCL_192,
	eCL_193,
	eCL_194,
	eCL_195,
	eCL_196,
	eCL_197,
	eCL_198,
	eCL_199,
	eCL_200,
	eCL_201,
	eCL_202,
	eCL_203,
	eCL_204,
	eCL_205,
	eCL_206,
	eCL_207,
	eCL_208,
	eCL_209,
	eCL_210,
	eCL_211,
	eCL_212,
	eCL_213,
	eCL_214,
	eCL_215,
	eCL_216,
	eCL_217,
	eCL_218,
	eCL_219,
	eCL_220,
	eCL_221,
	eCL_222,
	eCL_223,
	eCL_224,
	eCL_225,
	eCL_226,
	eCL_227,
	eCL_228,
	eCL_229,
	eCL_230,
	eCL_231,
	eCL_232,
	eCL_233,
	eCL_234,
	eCL_235,
	eCL_236,
	eCL_237,
	eCL_238,
	eCL_239,
	eCL_240,
	eCL_241,
	eCL_242,
	eCL_243,
	eCL_244,
	eCL_245,
	eCL_246,
	eCL_247,
	eCL_248,
	eCL_249,
	eCL_250,
	eCL_251,
	eCL_252,
	eCL_253,
	eCL_254,
	eCL_255,
	eCL_256,
	eCL_257,
	eCL_258,
	eCL_259,
	eCL_260,
	eCL_261,
	eCL_262,
	eCL_263,
	eCL_264,
	eCL_265,
	eCL_266,
	eCL_267,
	eCL_268,
	eCL_269,
	eCL_270,
	eCL_271,
	eCL_272,
	eCL_273,
	eCL_274,
	eCL_275,
	eCL_276,
	eCL_277,
	eCL_278,
	eCL_279,
	eCL_280,
	eCL_281,
	eCL_282,
	eCL_283,
	eCL_284,
	eCL_285,
	eCL_286,
	eCL_287,
	eCL_288,
	eCL_289,
	eCL_290,
	eCL_291,
	eCL_292,
	eCL_293,
	eCL_294,
	eCL_295,
	eCL_296,
	eCL_297,
	eCL_298,
	eCL_299,
	eCL_300,
	eCL_301,
	eCL_302,
	eCL_303,
	eCL_304,
	eCL_305,
	eCL_306,
	eCL_307,
	eCL_308,
	eCL_309,
	eCL_310,
	eCL_311,
	eCL_312,
	eCL_313,
	eCL_314,
	eCL_315,
	eCL_316,
	eCL_317,
	eCL_318,
	eCL_319,
	eCL_320,
	eCL_321,
	eCL_322,
	eCL_323,
	eCL_324,
	eCL_325,
	eCL_326,
	eCL_327,
	eCL_328,
	eCL_329,
	eCL_330,
	eCL_331,
	eCL_332,
	eCL_333,
	eCL_334,
	eCL_335,
	eCL_336,
	eCL_337,
	eCL_338,
	eCL_339,
	eCL_340,
	eCL_341,
	eCL_342,
	eCL_343,
	eCL_344,
	eCL_345,
	eCL_346,
	eCL_347,
	eCL_348,
	eCL_349,
	eCL_350,
	eCL_351,
	eCL_352,
	eCL_353,
	eCL_354,
	eCL_355,
	eCL_356,
	eCL_357,
	eCL_358,
	eCL_359,
	eCL_360,
	eCL_361,
	eCL_362,
	eCL_363,
	eCL_364,
	eCL_365,
	eCL_366,
	eCL_367,
	eCL_368,
	eCL_369,
	eCL_370,
	eCL_371,
	eCL_372,
	eCL_373,
	eCL_374,
	eCL_375,
	eCL_376,
	eCL_377,
	eCL_378,
	eCL_379,
	eCL_380,
	eCL_381,
	eCL_382,
	eCL_383,
	eCL_384,
	eCL_385,
	eCL_386,
	eCL_387,
	eCL_388,
	eCL_389,
	eCL_390,
	eCL_391,
	eCL_392,
	eCL_393,
	eCL_394,
	eCL_395,
	eCL_396,
	eCL_397,
	eCL_398,
	eCL_399,
	eCL_400,
	eCL_401,
	eCL_402,
	eCL_403,
	eCL_404,
	eCL_405,
	eCL_406,
	eCL_407,
	eCL_408,
	eCL_409,
	eCL_410,
	eCL_411,
	eCL_412,
	eCL_413,
	eCL_414,
	eCL_415,
	eCL_416,
	eCL_417,
	eCL_418,
	eCL_419,
	eCL_420,
	eCL_421,
	eCL_422,
	eCL_423,
	eCL_424,
	eCL_425,
	eCL_426,
	eCL_427,
	eCL_428,
	eCL_429,
	eCL_430,
	eCL_431,
	eCL_432,
	eCL_433,
	eCL_434,
	eCL_435,
	eCL_436,
	eCL_437,
	eCL_438,
	eCL_439,
	eCL_440,
	eCL_441,
	eCL_442,
	eCL_443,
	eCL_444,
	eCL_445,
	eCL_446,
	eCL_447,
	eCL_448,
	eCL_449,
	eCL_450,
	eCL_451,
	eCL_452,
	eCL_453,
	eCL_454,
	eCL_455,
	eCL_456,
	eCL_457,
	eCL_458,
	eCL_459,
	eCL_460,
	eCL_461,
	eCL_462,
	eCL_463,
	eCL_464,
	eCL_465,
	eCL_466,
	eCL_467,
	eCL_468,
	eCL_469,
	eCL_470,
	eCL_471,
	eCL_472,
	eCL_473,
	eCL_474,
	eCL_475,
	eCL_476,
	eCL_477,
	eCL_478,
	eCL_479,
	eCL_480,
	eCL_481,
	eCL_482,
	eCL_483,
	eCL_484,
	eCL_485,
	eCL_486,
	eCL_487,
	eCL_488,
	eCL_489,
	eCL_490,
	eCL_491,
	eCL_492,
	eCL_493,
	eCL_494,
	eCL_495,
	eCL_496,
	eCL_497,
	eCL_498,
	eCL_499,
	eCL_500,
	eCL_501,
	eCL_502,
	eCL_503,
	eCL_504,
	eCL_505,
	eCL_506,
	eCL_507,
	eCL_508,
	eCL_509,
	eCL_510,
	eCL_511,
	eCL_512,
	eCL_513,
	eCL_514,
	eCL_515,
	eCL_516,
	eCL_517,
	eCL_518,
	eCL_519,
	eCL_520,
	eCL_521,
	eCL_522,
	eCL_523,
	eCL_524,
	eCL_525,
	eCL_526,
	eCL_527,
	eCL_528,
	eCL_529,
	eCL_530,
	eCL_531,
	eCL_532,
	eCL_533,
	eCL_534,
	eCL_535,
	eCL_536,
	eCL_537,
	eCL_538,
	eCL_539,
	eCL_540,
	eCL_541,
	eCL_542,
	eCL_543,
	eCL_544,
	eCL_545,
	eCL_546,
	eCL_547,
	eCL_548,
	eCL_549,
	eCL_550,
	eCL_551,
	eCL_552,
	eCL_553,
	eCL_554,
	eCL_555,
	eCL_556,
	eCL_557,
	eCL_558,
	eCL_559,
	eCL_560,
	eCL_561,
	eCL_562,
	eCL_563,
	eCL_564,
	eCL_565,
	eCL_566,
	eCL_567,
	eCL_568,
	eCL_569,
	eCL_570,
	eCL_571,
	eCL_572,
	eCL_573,
	eCL_574,
	eCL_575,
	eCL_576,
	eCL_577,
	eCL_578,
	eCL_579,
	eCL_580,
	eCL_581,
	eCL_582,
	eCL_583,
	eCL_584,
	eCL_585,
	eCL_586,
	eCL_587,
	eCL_588,
	eCL_589,
	eCL_590,
	eCL_591,
	eCL_592,
	eCL_593,
	eCL_594,
	eCL_595,
	eCL_596,
	eCL_597,
	eCL_598,
	eCL_599,
	eCL_600,
	eCl_Building,			//����
	eCL_Special,			//����
	eCL_AllClass,			//����ְҵ
	eCL_Count
};

// ��Ӫ
enum ECamp
{
	eCamp_None			= 0,	// ��
	eCamp_AmyEmpire		= 1,	// ���׵۹�����
	eCamp_WestEmpire	= 2,	// ���۾�����
	eCamp_DevilIsland	= 3,	// ��ħ������
	eCamp_Passerby		= 4,	// ·��
	eCamp_Monster		= 5,	// ����
	eCamp_Chaos			= 6,	// ����
	
	//Ϊ�淨��������Ӫ
	eCamp_NoQuestPasserby	= 10,	// û���κ�����ͽ������ܵ�·��
	eCamp_Specail			= 11,	// ��0,5Ϊ�ж���Ӫ,������Ϊ�ѷ�
	eCamp_Count
};

// С��ͼ����
enum EMapRole
{ 
	eMR_Npc = 0, 
	eMR_PlayerPKSafe, 
	eMR_PlayerPKMatch,
	eMR_PlayerPKForce,
	eMR_TeamMate, 
	eMR_Player, 
	eMR_Count ,
};

enum ECoreObjectHandlerType
{
	eCOHT_None,
	eCOHT_Character,
	eCOHT_Magic,
	eCOHT_Obj,
};

enum EGameEntityType
{
	eGET_GameEntity, 
	eGET_CharacterDirector, 
	eGET_CharacterFollower,
	eGET_CharacterDictator,
	eGET_CharacterMediator,
	eGET_IntObject, 
};

enum ECharacterType
{
	eCT_Player	= 1,
	eCT_Npc,
	eCT_IntObj,
	eCT_Trap,
	eCT_Magic,
};

enum EObjectAoiType
{
	EAoi_TaskNpc			= 0x00000000,	//����Npc	eAIET_BlindObj eAIST_TaskObj
	EAoi_ActiveNpc			= 0x00000001,	//����Npc 	eAIET_VisiPlayerObj eAIST_PkMonster
	EAoi_PassiveNpc			= 0x00000002,	//����Npc	eAIET_BlindObj eAIST_PkMonster
	EAoi_NatureNpc			= 0x00000010,	//�и��ԵĹ���Npc eAIET_InterestedObj eAIST_TaskObj
	EAoi_NatureActiveNpc	= 0x00000011,	//�и��Ե������� eAIET_DoubleEyeSightVisiPlayerObj eAIST_Monster
	EAoi_NaturePassiveNpc	= 0x00000012,	//�и��Եı����� eAIET_DoubleEyeSightInvisiPlayerObj eAIST_Monster
	EAoi_ActiveServant,						//���������ٻ���	�ܿ�����ң�����Npc
	EAoi_PassiveServant,					//���������ٻ���	���ܿ����κζ���
	EAoi_BattleHorse,						//ս������
	EAoi_IntObjSeeNone,						//��������(���ܿ���Һ�Npc)		eAIET_BlindObj	eAIST_TaskObj
	EAoi_IntObjSeeAll,						//��������(�ܿ���Һ�Npc)		eAIET_VisiPlayerObj	eAIST_TaskObj
	EAoi_TrapSeeAll,						//����(�ܿ���Npc�����)	eAIET_VisiPlayerObj	eAIST_TaskObj
	EAoi_TrapSeePlayer,						//ֻ�ܿ�����ҵ�����
	EAoi_TrapSeeNpc,						//ֻ�ܿ���Npc������
	EAoi_SleepNPC,							//����NPC(�����κζ�����Ҳ���ܱ��κζ�������)
	EAoi_Null,

};

enum ENpcAIType
{
	ENpcAIType_None,
	ENpcAIType_NormalPassivityPatrol,						//��ͨ�ֱ���֧��Ѳ��
	ENpcAIType_NormalInitiativePatrolNoFefer,				//��ͨ������֧��Ѳ��
	ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc,		//��ͨ������֧��Ѳ�߿ɼ�Npc
	ENpcAIType_Task,										//����Npc
	ENpcAIType_PassivityCopIt,								//���򲻷���
	ENpcAIType_Totem,										//ͼ��
	ENpcAIType_Servant,										//�ٻ���
	ENpcAIType_VirtualNpc,									//����Npc֧��Ѳ��
	ENpcAIType_GroupMemberPassivity,						//Ⱥ���Ա������
	ENpcAIType_GroupMemberInitiative,						//Ⱥ���Ա������
	ENpcAIType_TowerAttack,									//����AI
	ENpcAIType_BattleHorse,									//ս������
	ENpcAIType_Building,									//���Npc(���������ӣ�ˢ�����ȵ�)
	ENpcAIType_OrdnanceMonster,								//��е��
	ENpcAIType_MagicBuilding,								//ħ����
	ENpcAIType_Cannon,										//�ƶ���̨
	ENpcAIType_MonsterCard,									//���￨
	ENpcAIType_Pet,											//����
	ENpcAIType_BossCortege,									//BossС��
	ENpcAIType_BossActive,									//Boss����֧��Ѳ��
	ENpcAIType_BossPassivity,								//Boss����֧��Ѳ��
	ENpcAIType_Theater,										//�糡Npc
	ENpcAIType_NotFightNonTask,								//���򲻻��ֲ�ת�������Npc
	ENpcAIType_Truck,										//���䳵
	ENpcAIType_Escape,										//����AI
	ENpcAIType_LittlePet,									//�������
};

enum ENpcType
{
	ENpcType_None,				//����Npc
	ENpcType_Normal,			//��ͨ����Npc������Npc�������֣������֣������ȵ�
	ENpcType_Totem,				//ͼ��
	ENpcType_Pet,				//����
	ENpcType_Summon,			//���������ٻ���			
	ENpcType_BattleHorse,		//ս������
	ENpcType_Dummy,				//����Npc
	ENpcType_Member,			//Ⱥ���Ա
	ENpcType_OrdnanceMonster,	//��е��
	ENpcType_MagicBuilding,		//ħ����
	ENpcType_Cannon,			//�ƶ���̨
	ENpcType_MonsterCard,		//���￨
	ENpcType_Shadow,			//����
	ENpcType_Truck,				//���䳵
	ENpcType_BossCortege,		//BossС��
	ENpcType_QuestBeckonNpc,	//�����ٻ�Npc
	ENpcType_AttackNearest,		//�������
	ENpcType_LittlePet,			//�������
	ENpcType_NotCtrlSummon,		//����Ҫ���������ٻ���
};

enum ETrapSeeType
{
	ETrapSeeType_None,
	ETrapSeeType_Player,
	ETrapSeeType_Npc,
	ETrapSeeType_All,
};

//enum EPKState
//{
//	ePKS_Safety	= 0,			// ��ȫ
//	ePKS_Rivalry,				// �Կ�
//	ePKS_Killer,				// ɱ¾
//};
//
//enum EZoneType
//{
//	eZT_AmyEmpire		= 1,	// ��������
//	eZT_WestEmpire		= 2,	// ��ʥ����
//	eZT_DevilIsland		= 3,	// ��˹����
//	eZT_CommonZone		= 4,	// ��������
//	eZT_NewCommonZone	= 5,	// �¹�������
//	eZT_WarZone			= 6,	// ��ս����
//	eZT_Other			= 7,	// ����
//};
