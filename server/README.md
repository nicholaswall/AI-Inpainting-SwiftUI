## Running the Server

1. Install all dependencies (`/app/requirements.txt`)
2. Ensure get a huggingface API token (may or may not be necessary depending on current state of StableDiffusion API)
   put a token in a `.env` file in the app directory.
3. In the app directory run `uvicorn main:app --reload`

If there are issues installing dependencies it likely has to do with compiler toolchains for `tokenizers` this is because the library is built with rust for the specific architecture of your CPU. if is the case run the following commands from the server folder

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

git clone https://github.com/huggingface/tokenizers
cd tokenizers/bindings/python
pip install setuptools_rust
python setup.py install
cd ../../../
pip install git+https://github.com/huggingface/transformers
```

4. Now that the server is running the mobile app needs to know your server URL, you can either use your IP if you already know if and use port 8000, or I would recommend the cloudflared tunnel. If you have cloudflared CLI you can just run:

```bash
cloudflared tunnel --url http://localhost:8000
```

5. Using whatever url you decide to use, add the URL to the Mobile App in `MagicEraser/MagicEraser/Utilties/NetworkManager.swift` by changing the static string called `baseURL`

# Important Notes

Server hardware must support mixed precision operations as the generator model must run in half precision
I would not recommend trying on on a serial processor, GPU is ideal but MPS works fine as I have enabled memory offloading for large models.
