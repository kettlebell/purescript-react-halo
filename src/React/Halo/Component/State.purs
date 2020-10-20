module React.Halo.Component.State where

import Prelude
import Data.Map (Map)
import Data.Map as Map
import Effect (Effect)
import Effect.Aff (Aff, Fiber)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import React.Halo.Component (Spec)
import React.Halo.Component.Control (ForkId, SubscriptionId)

newtype State props state action
  = State
  { component :: Spec props state action Aff
  , render :: state -> Effect Unit
  , unmounted :: Ref Boolean
  , props :: Ref props
  , state :: Ref state
  , fresh :: Ref Int
  , subscriptions :: Ref (Map SubscriptionId (Effect Unit))
  , forks :: Ref (Map ForkId (Fiber Unit))
  }

createInitialState :: forall props state action. Spec props state action Aff -> (state -> Effect Unit) -> props -> state -> Effect (State props state action)
createInitialState component render props' state' = do
  unmounted <- Ref.new false
  fresh' <- Ref.new 0
  props <- Ref.new props'
  state <- Ref.new state'
  subscriptions <- Ref.new Map.empty
  forks <- Ref.new Map.empty
  pure $ State { component, render, unmounted, props, state, fresh: fresh', subscriptions, forks }

fresh :: forall props state action a. (Int -> a) -> State props state action -> Effect a
fresh f (State state) = do
  Ref.modify' (\a -> { state: a + 1, value: f a }) state.fresh
