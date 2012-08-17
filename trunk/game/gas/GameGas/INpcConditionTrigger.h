/*
 * =====================================================================================
 *
 *       Filename:  INpcConditionTrigger.h
 *
 *    Description:  Npc����������
 *
 *        Version:  1.0
 *        Created:  2008��11��28�� 10ʱ53��05��
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  ����� (Comet), liaoxinwei@linekong.com
 *        Company:  ThreeOGCMan
 *
 * =====================================================================================
 */

#pragma once
class CNpcAI;
class INpcConditionTrigger
{
	public:
		virtual ~INpcConditionTrigger() { }
		virtual void Active() = 0;
		virtual void Freeze() = 0;
		virtual void Trigger() = 0;
		virtual bool Check() = 0;
		virtual INpcConditionTrigger* Clone() const = 0;
};
