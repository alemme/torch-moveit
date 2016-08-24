#include "torch-moveit.h"
#include <moveit/robot_model/robot_model.h>
#include "utils.h"

typedef robot_model::RobotModelPtr RobotModelPtr;

MOVIMP(RobotModelPtr*, RobotModel, new)()
{
   return new RobotModelPtr();
}

MOVIMP(void, RobotModel, delete)(RobotModelPtr *ptr)
{
  if (ptr)
    delete ptr;
}

MOVIMP(void, RobotModel, release)(RobotModelPtr *ptr)
{
  ptr->reset();
}

MOVIMP(const char *, RobotModel, getName)(RobotModelPtr *ptr)
{
  return (*ptr)->getName().c_str();
}

MOVIMP(const char *, RobotModel, getModelFrame)(RobotModelPtr *ptr)
{
  return (*ptr)->getModelFrame().c_str();
}

MOVIMP(bool, RobotModel, isEmpty)(RobotModelPtr *ptr)
{
  return (*ptr)->isEmpty();
}

MOVIMP(void, RobotModel, printModelInfo)(RobotModelPtr *ptr, std::string *output)
{
  std::stringstream s;
  (*ptr)->printModelInfo(s);
  *output = s.str();
}

MOVIMP(const char *, RobotModel, getRootJointName)(RobotModelPtr *ptr)
{
  return (*ptr)->getRootJointName().c_str();
}