--- LUA wrapper for moveit robot state environment
-- dependency to tourch.ros
-- @classmod RobotState
local ffi = require 'ffi'
local torch = require 'torch'
local ros = require 'ros'
local moveit = require 'moveit.env'
local utils = require 'moveit.utils'
local std = ros.std
local tf = ros.tf


local RobotState = torch.class('moveit.RobotState', moveit)

local f

function init()
  local RobotState_method_names = {
    "createEmpty",
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
    "setFromIK",
    "getGlobalLinkTransform",
    "setVariablePositions",
    "setVariableVelocities",
    "setVariableAccelerations",
    "setVariableEffort",
    "updateLinkTransforms",
    "toRobotStateMsg",
    "fromRobotStateMsg",
    "getJointTransform",
    "getJacobian",
    "enforceBounds",
    "distance",
    "satisfiesBounds"
  }

  f = utils.create_method_table("moveit_RobotState_", RobotState_method_names)
end

init()

function RobotState.createEmpty()
  local c = torch.factory('moveit.RobotState')()
  rawset(c, 'o', f.createEmpty())
  return c
end

function RobotState:__init(o)
  if type(o) ~= 'cdata' or ffi.typeof(o) ~= ffi.typeof('RobotStatePtr*') then
    error('RobotState object can only be initialized with existing RobotState pointer.')
  end
  self.o = o
  ffi.gc(o, f.delete)
  self.moveit_msgs_RobotStateSpec = ros.get_msgspec('moveit_msgs/RobotState')
end

function RobotState:cdata()
  return self.o
end

function RobotState:clone()
  local c = torch.factory('moveit.RobotState')()
  rawset(c, 'o', f.clone(self.o))
  return c
end

---Get the number of variables that make up this state.
--@treturn int
function RobotState:getVariableCount()
  return f.getVariableCount(self.o)
end

---Get the names of the variables that make up this state, in the order they are stored in memory.
--@tparam[opt] moveit.Strings names
--@treturn moveit.Strings
function RobotState:getVariableNames(names)
  names = names or std.StringVector()
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
--@treturn boolean
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
--This is useful to know when serializing or copying the state. If hasAccelerations() reports true, hasEffort() will certainly report false.
--@treturn boolean
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
--This is useful to know when serializing or copying the state. If hasEffort() reports true, hasAccelerations() will certainly report false.
--@treturn boolean
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
--@treturn boolean
function RobotState:setFromIK(group_id, pose, attempts, timeout, return_approximate_solution)
  attempts = attempts or 10
  timeout = timeout or 0.1
  return_approximate_solution = return_approximate_solution or false
  if torch.isTensor(pose) then
    pose = tf.Transform():fromTensor(pose)
  end
  local result_joint_positions = torch.DoubleTensor()
  local found_ik = f.setFromIK(self.o, group_id, pose:cdata(), attempts, timeout, return_approximate_solution, result_joint_positions:cdata())
  return found_ik, result_joint_positions
end

---Do forward Kinematic
--@tparam tf.Transform pose
--@tparam string link name
function RobotState:getGlobalLinkTransform(link_name, pose)
  pose = pose or tf.Transform()
  f.getGlobalLinkTransform(self.o, pose:cdata(), link_name)
  return pose
end

---It is assumed positions is an array containing the new positions for all variables in this state. Those values are copied into the state.
--
function RobotState:setVariablePositions(group_variable_values)
  return f.setVariablePositions(self.o, group_variable_values:cdata())
end

---It is assumed positions is an array containing the new velocities for all variables in this state. Those values are copied into the state.
--
function RobotState:setVariableVelocities(group_variable_values)
  return f.setVariableVelocities(self.o, group_variable_values:cdata())
end

---It is assumed positions is an array containing the new accelerations for all variables in this state. Those values are copied into the state.
--
function RobotState:setVariableAccelerations(group_variable_values)
  return f.setVariableAccelerations(self.o, group_variable_values:cdata())
end

---It is assumed positions is an array containing the new effort for all variables in this state. Those values are copied into the state.
--
function RobotState:setVariableEffort(group_variable_values)
  return f.setVariableEffort(self.o, group_variable_values:cdata())
end

---Update the reference frame transforms for links. This call is needed before using the transforms of links for coordinate transforms.
--
function RobotState:updateLinkTransforms()
  f.updateLinkTransforms (self.o)
end

---Convert Robotstate to Message format
--@tparam boolean copy_attached_bodies
function RobotState:toRobotStateMsg(copy_attached_bodies)
  copy_attached_bodies = copy_attached_bodies or false
  local msg_bytes = torch.ByteStorage()
  f.toRobotStateMsg(self.o, msg_bytes:cdata(),copy_attached_bodies)
  local msg = ros.Message(self.moveit_msgs_RobotStateSpec, true)
  msg:deserialize(msg_bytes)
  return msg
end

---Convert Message format to Robotstate
--@tparam Robotstate_msg msg
function RobotState:fromRobotStateMsg(msg)
   if torch.isTypeOf(msg, ros.Message) then
    local msg_bytes = msg:serialize()
    msg_bytes:shrinkToFit()
    f.fromRobotStateMsg(self.o, msg_bytes.storage:cdata())
    return true
  end
  return false
end

---Determines joint transformation from joint name
--@tparam string joint_name
function RobotState:getJointTransform(joint_name)
  assert(joint_name and type(joint_name) == 'string' and #joint_name >= 0, 'Invalid joint_name specified.')
  local result = torch.DoubleTensor()
  f.getJointTransform(self.o, joint_name, result:cdata())
  return result
end

---Determines Jacobian for move group name
--@tparam string group_name
function RobotState:getJacobian(group_name)
  assert(group_name and type(group_name) == 'string' and #group_name >= 0, 'Invalid group_name specified.')
  local result = torch.DoubleTensor()
  f.getJacobian(self.o, group_name, result:cdata())
  return result
end

function RobotState:enforceBounds()
  f.enforceBounds()
end

function RobotState:distance(other)
  if torch.isTypeOf(other,moveit.RobotState) then
    return f.distance(self.o,other:cdata())
  end
end

function RobotState:satisfiesBounds(margin)
  local margin = margin or 0.0
  return f.satisfiesBounds(margin)
end