import React, { useState } from "react";
import styles from '../styles/Home.module.css';
import Web3Modal from "web3modal";
import { ethers } from "ethers";
import CoinbaseWalletSDK from '@coinbase/wallet-sdk';
import WalletConnectProvider from "@walletconnect/web3-provider";
import Torus from "@toruslabs/torus-embed";



export default function Home() {

    const [connectedUser, setConnectedUser] = useState(null);
    const [walletConnected, setWalletConnected] = useState(false);

   /*
   @dev We can add wallets providers as Coinbase, metamask, walletconnect via Web3Modal
   */
    const providerOptions={
        coinbasewallet : {
          package:CoinbaseWalletSDK,
          options:{
            appName: "task",
            infuraId:"e0fa9560e5fa49bca7ecb3b3314b81e3",
            chainId:420,
          }
        },
        walletconnect:{
          package:WalletConnectProvider,
          options:{
            infuraId:"e0fa9560e5fa49bca7ecb3b3314b81e3",
          }

        },
        torus:{
          package:Torus,
          
        },
        
    
    }

    
    const connectWallet = async () => {
        try{

            const web3Modal = new Web3Modal(
                {
                    network:"mainnet",
                    cacheProvider:false,
                    providerOptions,

                }
            )
            
            
            const web3ModalInstance = await web3Modal.connect();
            
            
            const provider = new ethers.providers.Web3Provider(web3ModalInstance);
            
            setWalletConnected(true);
            
           

            const signer = provider.provider.selectedAddress;
            setConnectedUser(signer);
        }

        catch(err){
            console.error(err);
        }
    }

    return(
        <div>
      <h1>Task</h1>
      <div className={styles.main}>
        {!walletConnected ? 
        ( <div>
            Please connect the wallet : 
            <button className={styles.connect_button} onClick={connectWallet}>
            Connect Wallet
            </button>
          </div>)
          :(
            <div>
                <div>Connected User : {connectedUser}</div>
            </div>
          )}<br></br>
      </div>
      <footer className={styles.footer}> FOOTER </footer>
    </div>
  )
  
    }
   
  
  
