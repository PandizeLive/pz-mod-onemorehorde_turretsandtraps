testH474={core=OneMoreHordeDefenseIntegration,engine=OneMoreHordePhase3HordeEngine,flags=__modules.OMH_RunFlags,runtime=__modules.OMH_DifficultyRuntime,mode=testMode}
testMode="sp"
OneMoreHordeDefenseIntegration=nil
testH474.owner={defensesEnabled=false,difficultySelectionConfirmed=true}
testH474.event={}
testH474.flagsApplied=0
OneMoreHordePhase3HordeEngine={defenseContext=function() return "active",testH474.owner,testH474.event end}
__modules.OMH_RunFlags={DEFENSE_USED="defense-used"}
__modules.OMH_DifficultyRuntime={applyIntegrityFlag=function() testH474.flagsApplied=testH474.flagsApplied+1 end,
 getEventClassificationSnapshot=function() return {integrityFlags={["defense-used"]=true}} end}
