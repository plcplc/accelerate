{-# LANGUAGE CPP #-}
-- |
-- Module      : Data.Array.Accelerate.Debug
-- Copyright   : [2008..2011] Manuel M T Chakravarty, Gabriele Keller, Sean Lee
--               [2009..2012] Manuel M T Chakravarty, Gabriele Keller, Trevor L. McDonell
-- License     : BSD3
--
-- Maintainer  : Manuel M T Chakravarty <chak@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--
-- Embedded array processing language: debugging support (internal). This module
-- provides functionality that is useful for developers of the library.  It is
-- not meant for library users.
--

module Data.Array.Accelerate.Debug (

  -- * Conditional tracing
  initTrace, queryTrace, traceLine, traceChunk, tracePure

) where

-- standard libraries
import Control.Monad
import Data.IORef
import Debug.Trace
import System.IO.Unsafe (unsafePerformIO)

-- friends
import Data.Array.Accelerate.Pretty ()

#if __GLASGOW_HASKELL__ < 704
traceIO :: String -> IO ()
traceIO = putTraceMsg
#endif

-- This flag indicates whether tracing messages should be emitted.
--
traceFlag :: IORef Bool
{-# NOINLINE traceFlag #-}
traceFlag = unsafePerformIO $ newIORef False

-- Initialise the /trace flag/, which determines whether tracing messages should
-- be emitted.
--
initTrace :: Bool -> IO ()
initTrace = writeIORef traceFlag

-- Read the value of the /trace flag/.
--
queryTrace :: IO Bool
queryTrace = readIORef traceFlag

-- Emit a trace message if the /trace flag/ is set.  The first string indicates
-- the location of the message.  The second one is the message itself.  The
-- output is formatted to be on one line.
--
traceLine :: String -> String -> IO ()
traceLine header msg
  = do { doTrace <- queryTrace
       ; when doTrace 
         $ traceIO (header ++ ": " ++ msg)
       }

-- Emit a trace message if the /trace flag/ is set.  The first string indicates
-- the location of the message.  The second one is the message itself.  The
-- output is formatted over multiple lines.
--
traceChunk :: String -> String -> IO ()
traceChunk header msg
  = do { doTrace <- queryTrace
       ; when doTrace 
         $ traceIO (header ++ "\n  " ++ msg)
       }

-- Perform 'traceLine' in a pure computation.
--
tracePure :: String -> String -> a -> a
tracePure header msg val = unsafePerformIO (traceLine header msg) `seq` val
