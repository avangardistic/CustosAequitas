#ifndef HARDENING_MANAGER_MQH
#define HARDENING_MANAGER_MQH
#include <CustosAequitas\Constants.mqh>
#include <CustosAequitas\BrokerScorer.mqh>

class CHardeningManager {
private:
   CBrokerScorer* m_scorer; double m_baseRisk; double m_stopBuffer; bool m_enabled;
   ENUM_BROKER_GRADE m_currentGrade;
public:
   CHardeningManager() { m_scorer=NULL; m_baseRisk=2.0; m_stopBuffer=5.0; m_enabled=false; m_currentGrade=GRADE_A; }
   void SetBaseRisk(double r) { m_baseRisk=r; }
   void SetStopBuffer(double p) { m_stopBuffer=p; }
   void Enable(bool e) { m_enabled=e; }
   void SetBrokerScorer(CBrokerScorer* s) { m_scorer=s; }
   
   void UpdateScore(ENUM_BROKER_GRADE g, double score, double conf) { m_currentGrade=g; }
   
   double GetAdjustedRisk() {
      if(!m_enabled) return m_baseRisk;
      switch(m_currentGrade) {
         case GRADE_A: return m_baseRisk;
         case GRADE_B: return m_baseRisk * 0.75;
         case GRADE_C: return m_baseRisk * 0.50;
         case GRADE_D: return m_baseRisk * 0.25;
         case GRADE_F: return 0;
      }
      return m_baseRisk;
   }
   
   double GetStopHardening() {
      if(!m_enabled) return m_stopBuffer;
      switch(m_currentGrade) {
         case GRADE_A: return m_stopBuffer;
         case GRADE_B: return m_stopBuffer * 1.2;
         case GRADE_C: return m_stopBuffer * 1.5;
         case GRADE_D: return m_stopBuffer * 2.0;
         case GRADE_F: return m_stopBuffer * 3.0;
      }
      return m_stopBuffer;
   }
};
#endif
