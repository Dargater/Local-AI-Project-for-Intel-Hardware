cd optimum_cli.venv

cd scripts

.\activate.ps1

cd ..\

cd ..\
cd models

cmd /c '"..\ovms\setupvars.bat" && "..\ovms\ovms.exe" --source_model .\Qwen3-VL-8B-Instruct-int4-ov --model_repository_path . --model_name Qwen3-VL-8B-Instruct-int4-ov --task text_generation --pipeline_type VLM_CB --target_device GPU --rest_port 8000'
