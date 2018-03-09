import Haskus.System
import Haskus.System.Linux.Graphics.State
import Haskus.System.Linux.Graphics.Config
import qualified Haskus.Utils.Map as Map


main :: IO ()
main = runSys' <| do

   sys   <- defaultSystemInit
   term  <- defaultTerminal

   -- get graphic card devices
   cards <- loadGraphicCards (systemDeviceManager sys)
   
   forM_ cards <| \card -> do
      state <- readGraphicsState (graphicCardHandle card)
               >..~!!> assertShow "Cannot read graphics state"

      let
         showProps o =
            graphicsConfig (graphicCardHandle card) (getPropertyM o)
            >.~!> (\props -> writeStrLn term ("  * Properties: " ++ show props))
         
      writeStrLn term "Connectors:"
      mapM_ showProps (Map.elems (graphicsConnectors state))
      writeStrLn term "Encoders:"
      mapM_ showProps (Map.elems (graphicsEncoders state))
      writeStrLn term "Controllers:"
      mapM_ showProps (Map.elems (graphicsControllers state))
      writeStrLn term "Planes:"
      mapM_ showProps (Map.elems (graphicsPlanes state))

   sysLogPrint
   powerOff