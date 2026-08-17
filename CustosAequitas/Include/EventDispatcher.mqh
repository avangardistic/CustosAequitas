#ifndef EVENT_DISPATCHER_MQH
#define EVENT_DISPATCHER_MQH
#include <CustosAequitas\Constants.mqh>

class CEventDispatcher {
public:
   CEventDispatcher() {}
   ~CEventDispatcher() {}
   void Dispatch(string event, double data) {}
};
#endif
