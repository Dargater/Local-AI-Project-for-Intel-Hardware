# Local-AI-Project-for-Intel-Hardware
Scripts to install and run AI utilities on Intel Hardware.
SO THIS IS MY FIRST EVER PROJECT SO PLEASE GO EASY ON ME.

The project is mainly for budget laptops with Intel Processors with no dedicated graphics driver. The backed used here is OpenVino Model Server. It is 
optimized for intel hardware including GPU, CPU and NPU. With this backend installed you should be able customize what you want to use to run the model.
However if you wish to run a custom model you should visit https://huggingface.co/OpenVINO/collections. The Models listed here should work flawlessly.

The setup should install Dify and Open Web UI which are the best front ends I found so far. Docling could be helpful if you want document parsing. It is recommended you have at least 16 GB RAM to run two models one on GPU using OVMS and one on CPU using llama.cpp simultaneously on windows operating system. This project was aimed for people with office laptops meant for productivity so I chose windows however I plan to make one for Bazzite, an immutable Fedora Based distro, specifically because it has gained most popularity among windows users who want convenience.

You should also ensure your hardware is supported for OpenVino at https://docs.openvino.ai/2026/about-openvino/release-notes-openvino/system-requirements.html

If not llama.cpp is probably your only option.

INSTALLATION
------------

Go to root directory. Anything you run should be in the root project directory.

Open powershell as administrator to this root folder and then run the following commands:
`powershell -ExecutionPolicy Bypass -File .\Setup.ps1`

The script should handle the rest.

After installation has completed run each of the scripts you want but ensure you bypass execution policy:

Open powershell as administrator to this root folder and then run the following commands:
`powershell -ExecutionPolicy Bypass -File .\YourScript.ps1`


Also if you want to use the model on openwebui or dify ensure you use exactly this as the api url:

`http://localhost:8000/v3/`

For any other api follow this format excluding the v3 and using respective ports


Third-party components used

Dify — https://github.com/langgenius/dify — License: modified Apache 2.0 with additional conditions (see LICENSE)
Open WebUI — https://github.com/open-webui/open-webui — License: Open WebUI License (see LICENSE)
OpenVINO Model Server — https://github.com/openvinotoolkit/model_server — License: Apache 2.0
Docling — https://github.com/docling-project/docling — License: MIT
Optimum — https://github.com/huggingface/optimum — License: Apache 2.0
Apache Tika — https://github.com/apache/tika — License: Apache 2.0
