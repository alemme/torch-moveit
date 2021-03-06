--- LUA wrapper for moveit robot state environment
-- dependency to tourch.ros
-- @classmod RobotState
local ffi = require 'ffi'
local torch = require 'torch'
local moveit = require 'moveit.env'
local utils = require 'moveit.utils'
local ros = require 'ros'
local tf = ros.tf


local RobotState = torch.class('moveit.RobotState', moveit)

local f

function init()
  local RobotState_method_names = {
    "clone",
    "delete",
    "release",
    "getVariableCount",
    "getVariableNames",
    "getVariablePositions",
    "hasVelocities",
    "getVariableVelocities",
    "hasAccelerations",
    "getVariableAccelerations",
    "hasEffort",
    "getVariableEffort",
    "setToDefaultValues",
    "setToRandomPositions",
    "setFromIK"
  }

  f = utils.create_method_table("moveit_RobotState_", RobotState_method_names)
end

init()

function RobotState:__init(o)
  if type(o) ~= 'cdata' or ffi.typeof(o) ~= ffi.typeof('RobotStatePtr*') then
    error('RobotState object can only be initialized with existing RobotState pointer.')
  end
  self.o = o
  ffi.gc(o, f.delete)
end

function RobotState:cdata()
  return self.o
end

function RobotState:clone()
  local c = torch.factory('moveit.RobotState')()
  rawset(c, 'o', f.clone(self.o))
  return c
end

---function getVariableNames
--Get the number of variables that make up this state.
--@treturn int
function RobotState:getVariableCount()
  return f.getVariableCount(self.o)
end

---Get the names of the variables that make up this state, in the order they are stored in memory.
--@tparam[opt] moveit.Strings names
--@treturn moveit.Strings
function RobotState:getVariableNames(names)
  names = names or moveit.Strings()
  f.getVariableNames(self.o, names:cdata())
  return names
end

---Get a raw pointer to the positions of the variables stored in this state. Use carefully.
--If you change these values externally you need to make sure you trigger a forced update for the state by calling update(true).
--@treturn torch.DoubleTensor
function RobotState:getVariablePositions()
  local t = torch.DoubleTensor()
  f.getVariablePositions(self.o, t:cdata())
  return t
end

---By default, if velocities are never set or initialized, the state remembers that there are no velocities set.
--This is useful to know when serializing or copying the state.
--@treturn bool
function RobotState:hasVelocities()
  return f.hasVelocities(self.o)
end

---Get const access to the velocities of the variables that make up this state. 
--The values are in the same order as reported by getVariableNames.
--@see getVariableNames
--@treturn torch.DoubleTensor
function RobotState:getVariableVelocities()
  local t = torch.DoubleTensor()
  f.getVariableVelocities(self.o, t:cdata())
  return t
end

---Check if accelerations are provided.
--By default, if accelerations are never set or initialized, the state remembers that there are no accelerations set.
--This is useful to know when serializing or copying the state. If @see hasAccelerations() reports true, @see hasEffort() will certainly report false.
--@treturn bool
function RobotState:hasAccelerations()
  return f.hasAccelerations(self.o)
end

---Get raw access to the accelerations of the variables that make up this state.
--The values are in the same order as reported by getVariableNames().
--The area of memory overlaps with effort (effort and acceleration should not be set at the same time)
--@treturn torch.DoubleTensor
--@see getVariableNames
function RobotState:getVariableAccelerations()
  local t = torch.DoubleTensor()
  f.getVariableAccelerations(self.o, t:cdata())
  return t
end

---Check if efforts are provided.
--By default, if effort is never set or initialized, the state remembers that there is no effort set.
--This is useful to know when serializing or copying the state. If @see hasEffort() reports true, @see hasAccelerations() will certainly report false.
--@treturn bool
function RobotState:hasEffort()
  return f.hasEffort(self.o)
end

---Get raw access to the effort of the variables that make up this state.
--The values are in the same order as reported by getVariableNames().
--@treturn torch.DoubleTensor
--@see getVariableNames
function RobotState:getVariableEffort()
  local t = torch.DoubleTensor()
  f.getVariableEffort(self.o, t:cdata())
  return t
end

---Set all joints to their default positions. 
--The default position is 0, or if that is not within bounds then half way between min and max bound.
function RobotState:setToDefaultValues()
  f.setToDefaultValues(self.o)
end

---Set all joints to random values.
--Values will be within default bounds.
function RobotState:setToRandomPositions()
  f.setToRandomPositions(self.o)
end

---If the group this state corresponds to is a chain and a solver is available, then the joint values can be set by computing inverse kinematics.
--The pose is assumed to be in the reference frame of the kinematic model.
--Returns true on success.
--@tparam string group_id
--@tparam tf.Transform pose
--@tparam[opt=10] int attempts
--@tparam[opt=0.1] number timeout
--@treturn bool
function RobotState:setFromIK(group_id, pose, attempts, timeout)
  attempts = attempts or 10
  timeout = timeout or 0.1
  local result_joint_positions = torch.DoubleTensor()
  local found_ik = f.setFromIK(self.o, group_id, pose:cdata(), attempts, timeout, result_joint_positions:cdata())
  return found_ik, result_joint_positions
end
