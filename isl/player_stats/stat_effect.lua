--[[ Models a single persistent stat effect and provides utilities upon it ]]
require "/scripts/questgen/util.lua"

-- Class ----------------------------------------------------------------------

ISLStatEffect = ISLStatEffect or createClass("ISLStatEffect")

-- Constructor ----------------------------------------------------------------

function ISLStatEffect:init(effect)
  if effect then
    self.stat = effect.stat
    if effect.amount then
      self.amount = effect.amount
    end
    if effect.baseMultiplier then
      self.baseMultiplier = effect.baseMultiplier
    end
    if effect.effectiveMultiplier then
      self.effectiveMultiplier = effect.effectiveMultiplier
    end
  end
end

-- Methods --------------------------------------------------------------------

function ISLStatEffect:default(stat_name)
  self.stat = self.stat or stat_name
  self.amount = self.amount or 0
  self.baseMultiplier = self.baseMultiplier or 1
  self.effectiveMultiplier = self.effectiveMultiplier or 1

  return self
end

function ISLStatEffect:set_stat(stat_name)
  self.stat = stat_name

  return self
end

function ISLStatEffect:adjust_amount(amount)
  self.amount = (self.amount or 0) + (amount or 0)

  return self
end

function ISLStatEffect:adjust_baseMultiplier(baseMultiplier)
  self.baseMultiplier = (self.baseMultiplier or 0) + (baseMultiplier or 0)

  return self
end

function ISLStatEffect:adjust_effectiveMultiplier(effectiveMultiplier)
  self.effectiveMultiplier =
    (self.effectiveMultiplier or 0) + (effectiveMultiplier or 0)

  return self
end

function ISLStatEffect:concat(effect)
  return self:adjust_amount(
    effect.amount
  ):adjust_baseMultiplier(
    effect.baseMultiplier
  ):adjust_effectiveMultiplier(
    effect.effectiveMultiplier
  )
end

function ISLStatEffect:over_amount(fn)
  self.amount = fn(self.amount or 0)

  return self
end

function ISLStatEffect:over_baseMultiplier(fn)
  self.baseMultiplier = fn(self.baseMultiplier or 0)

  return self
end

function ISLStatEffect:over_effectiveMultiplier(fn)
  self.effectiveMultiplier = fn(self.effectiveMultiplier or 0)

  return self
end

function ISLStatEffect:over_all(fn)
  return self:over_amount(fn):over_baseMultiplier(fn):over_effectiveMultiplier(fn)
end

function ISLStatEffect:rebase()
  if self.baseMultiplier and self.baseMultiplier ~= 1 then
    self.baseMultiplier = self.baseMultiplier - 1
  end
  if self.effectiveMultiplier and self.effectiveMultiplier ~= 1 then
    self.effectiveMultiplier = self.effectiveMultiplier - 1
  end

  return self
end

function ISLStatEffect:to_persistent_effect()
  local result = nil
  if self.amount and self.amount ~= 0 then
    result = result or { stat = self.stat }
    result.amount = self.amount
  end
  if self.baseMultiplier and self.baseMultiplier ~= 0 then
    result = result or { stat = self.stat }
    result.baseMultiplier = self.baseMultiplier + 1
  end
  if self.effectiveMultiplier and self.effectiveMultiplier ~= 0 then
    result = result or { stat = self.stat }
    result.effectiveMultiplier = self.effectiveMultiplier + 1
  end

  return result
end

function ISLStatEffect:to_mcontroller_effect(offset)
  return (offset + (self.amount or 0)) *
    (self.baseMultiplier or 1) *
    (self.effectiveMultiplier or 1)
end
