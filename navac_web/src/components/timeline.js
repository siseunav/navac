import React, { useState, useEffect } from "react";
import { collection, query, orderBy, limit, onSnapshot } from "firebase/firestore";
import { db } from "../firebase";
import Shully from "./shully";
import { HomeWrapper } from "./auth-Components";

export default function Timeline() {
    const [shullys, setShullys] = useState([]);

    useEffect(() => {
        const shullysQuery = query(
            collection(db, "shullys"),
            orderBy("createdAt", "desc"),
            limit(25)
        );

        const unsubscribe = onSnapshot(shullysQuery, (snapshot) => {
            const shullyData = snapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));
            setShullys(shullyData);
        });

        return () => unsubscribe();
    }, []);

    return (
        <HomeWrapper>
            {shullys.length > 0 ? (
                shullys.map((shully) => <Shully key={shully.id} {...shully} />)
            ) : (
                <p>No data available.</p>
            )}
        </HomeWrapper>
    );
}
