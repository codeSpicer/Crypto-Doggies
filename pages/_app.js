import "../styles/globals.css";
import Link from "next/link";

import "@rainbow-me/rainbowkit/styles.css";
import {
  ConnectButton,
  getDefaultWallets,
  RainbowKitProvider,
} from "@rainbow-me/rainbowkit";
import { chain, configureChains, createClient, WagmiConfig } from "wagmi";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";

const { chains, provider } = configureChains(
  [chain.polygon, chain.polygonMumbai],
  [alchemyProvider({ alchemyId: process.env.ALCHEMY_ID }), publicProvider()]
);

const { connectors } = getDefaultWallets({
  appName: "My RainbowKit App",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});

function MyApp({ Component, pageProps }) {
  return (
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <div className="bg-black">
          <nav className="border-b p-8">
            <p className="text-4xl font-bold text-white">NFT Marketplace</p>
            <div className="flex mt-4">
              <Link href="/">
                <a className="mr-4 text-pink-500">Home</a>
              </Link>
              <Link href="/create-nft">
                <a className="mr-6 text-pink-500">Sell NFT</a>
              </Link>
              <Link href="/my-nfts">
                <a className="mr-6 text-pink-500">My NFTs</a>
              </Link>
              <Link href="/dashboard">
                <a className="mr-6 text-pink-500">Dashboard</a>
              </Link>
              <ConnectButton
                accountStatus={{
                  smallScreen: "avatar",
                  largeScreen: "full",
                }}
              />
            </div>
          </nav>
          <Component {...pageProps} />
        </div>
      </RainbowKitProvider>
    </WagmiConfig>
  );
}

export default MyApp;
