const { useEffect, useState } = React;

function App() {
    const [cfg, setCfg] = useState(null);
    const [data, setData] = useState(null);
    const [err, setErr] = useState(null);

    useEffect(() => {
        (async () => {
            try {
                // טוען קונפיג מה-S3 (באותו origin)
                const cfgRes = await fetch("./config.json", { cache: "no-store" });
                if (!cfgRes.ok) throw new Error("Failed to load config.json: HTTP " + cfgRes.status);
                const cfgJson = await cfgRes.json();
                setCfg(cfgJson);

                const apiBase = (cfgJson.apiBaseUrl || "").replace(/\/+$/, "");
                const url = `${apiBase}/hello`;

                const r = await fetch(url);
                if (!r.ok) throw new Error("API error: HTTP " + r.status);
                const j = await r.json();
                setData(j);
            } catch (e) {
                setErr(String(e));
            }
        })();
    }, []);

    return (
        <div className="card">
            <h1>S3 + API Gateway + Lambda (Terraform)</h1>

            {err && <p><b>Error:</b> {err}</p>}

            {!err && !data && <p>Loading...</p>}

            {cfg && <p><b>API Base:</b> {cfg.apiBaseUrl}</p>}

            {data && (
                <>
                    <p><b>Message:</b> {data.message}</p>
                    <p><b>Time:</b> {data.time}</p>
                    <p><b>Visits:</b> {data.visits}</p>
                </>
            )}
        </div>
    );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
