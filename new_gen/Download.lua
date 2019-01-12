--[[ Create recursive add file function ]]--
 
local function AddDir(dir) --recursively adds everything in a directory to be downloaded by client
        local files, folders = file.Find(dir.."/*", "GAME")
 
        for _, fdir in pairs(folders) do
                if fdir != ".svn" then // don't spam people with useless .svn folders
                        AddDir(dir.."/"..fdir)
                end
        end
 
        for k,v in pairs(files) do
                resource.AddFile(dir.."/"..v)
        end
end
 
--[[ Add directory containing multiple files below using " AddDir("") " ]]--
--Временная закачка файлов
--resource.AddFile("sound/rts_music/1.mp3")
--resource.AddFile("sound/rts_music/2.mp3")
--resource.AddFile("sound/rts_music/3.mp3")
--resource.AddFile("sound/rts_music/4.mp3")
--resource.AddFile("sound/rts_music/5.mp3")
--resource.AddFile("sound/rts_music/6.mp3")
--resource.AddFile("sound/rts_music/7.mp3")
--resource.AddFile("sound/rts_music/8.mp3")
--resource.AddFile("sound/rts_music/9.mp3")
--resource.AddFile("sound/rts_music/10.mp3")
--resource.AddFile("sound/rts_music/11.mp3")
--resource.AddFile("sound/rts_music/12.mp3")
--resource.AddFile("sound/rts_music/13.mp3")
--resource.AddFile("sound/rts_music/14.mp3")
--resource.AddFile("sound/rts_music/15.mp3")
--resource.AddFile("sound/rts_music/16.mp3")
AddDir("materials/RTS_MelonWars")