import React, { useEffect, useState } from "react";
import styled from "styled-components";
import { auth, db } from "../firebase";
import { collection, query, where, getDocs, limit } from "firebase/firestore";
import Monolog from "../components/monologForm"; // Monolog 컴포넌트 가져오기
import { ProfileWrapper, UserProfileName, GlobalStyles } from "../components/auth-Components";
import cloudeImage from "../styled/imgs/cloude.jpg";

// 스타일 정의
const MonologWrapper = styled.div`
  display: flex;
  flex-direction: column;
  align-items: stretch;
  justify-content: flex-start;
  gap: 20px;
  padding: 20px;
  box-sizing: border-box;
`;


// MonologPage 컴포넌트
export default function MonologPage() {
  const user = auth.currentUser;
  const [monologs, setMonologs] = useState([]); // 사용자 Monolog 목록

  useEffect(() => {
    const fetchMonologs = async () => {
      if (!user?.uid) {
        console.error("User is not authenticated.");
        return;
      }

      const monologQuery = query(
        collection(db, "monologs"),
        where("userid", "==", user.uid),
        limit(25)
      );

      try {
        const snapshot = await getDocs(monologQuery);
        const fetchedMonologs = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setMonologs(fetchedMonologs);
      } catch (error) {
        console.error("Error fetching monologs:", error);
      }
    };

    fetchMonologs();
  }, [user]);

  return (

      

      <MonologWrapper>
        <GlobalStyles />
            <Monolog /> {/* Monolog 작성 폼 */}
        {monologs.map((monolog) => (
          <div key={monolog.id}>
            <h3>{monolog.username}</h3>
            <p>{monolog.monolog}</p>
            {monolog.photo && <img src={monolog.photo} alt="Uploaded" style={{ maxWidth: "100%" }} />}
            {monolog.video && (
              <video controls style={{ maxWidth: "100%" }}>
                <source src={monolog.video} type="video/mp4" />
                Your browser does not support the video tag.
              </video>
            )}
          </div>
        ))}
      </MonologWrapper>
  );
}
