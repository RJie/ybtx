// stdafx.h : ��׼ϵͳ�����ļ��İ����ļ���
// ���ǳ��õ��������ĵ���Ŀ�ض��İ����ļ�
//

#pragma once
#include "Base.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include <set>
#include <iostream>
#include <fstream>
#include <strstream>
#include <string>
#include <vector>
#include <map>
#include <list>
#include <stack>
#include <cstring>
#include <memory>
#include <algorithm>

#if defined(_WIN32) || defined(_USE_STLPORT)
#include <hash_map>
using namespace stdext;
#else
#include <ext/hash_map>
using namespace __gnu_cxx;
#endif

using namespace std;

#include "Base.h"

using namespace sqr;


// TODO: �ڴ˴����ó���Ҫ��ĸ���ͷ�ļ�
