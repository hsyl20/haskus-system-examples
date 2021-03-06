{-# LANGUAGE OverloadedStrings #-}

import Haskus.System
import Haskus.System.Linux.Graphics.State
import Haskus.System.Linux.Graphics.AtomicConfig
import qualified Haskus.Utils.Map as Map


main :: IO ()
main = runSys' <| do

   sys   <- defaultSystemInit
   term  <- defaultTerminal

   -- get graphic card devices
   cards <- loadGraphicCards (systemDeviceManager sys)
   
   forM_ cards <| \card -> do
      state <- evalCatchFlow (assertShow "Cannot read graphics state")
                  <| readGraphicsState (graphicCardHandle card)

      let
         showProps o = do
            mprops <- graphicsConfig (graphicCardHandle card) <|
                        evalCatchFlow (lift . assertShow "Query properties") (getPropertyM o)
            forM_ mprops <| \props ->
               writeStrLn term ("  * Properties: " ++ show props)
         
      writeStrLn term "Connectors:"
      mapM_ showProps (Map.elems (graphicsConnectors state))
      writeStrLn term "Encoders:"
      mapM_ showProps (Map.elems (graphicsEncoders state))
      writeStrLn term "Controllers:"
      mapM_ showProps (Map.elems (graphicsControllers state))
      writeStrLn term "Planes:"
      mapM_ showProps (Map.elems (graphicsPlanes state))
      mapM_ (writeStrLn term . show) (graphicsPlanes state)

   sysLogPrint
   powerOff
