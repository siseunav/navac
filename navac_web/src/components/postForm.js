import React, { useState } from 'react';
import { auth, db, storage } from "../firebase";
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { serverTimestamp,addDoc, collection, updateDoc } from "firebase/firestore";
import { PostFormWrapper, PostTextArea, PostSubmitBtn, AttachFileButton, AttachFileInput} from "./auth-Components";


export default function PostForm(){
    const [isLoading, setLoading] = useState(false);
    const[shully, setShully] = useState("");
    // const [file, setFile] = useState<File | null>(null); // 해당코드를 바꿔줬다. 
    const[file, setFile] = useState(null);


    const onChange = (e) => {
        setShully(e.target.value || "");// 문자열 아니면 공백
    };
    // e: React.ChangeEvent<HTMLTextAreaElement> <- 이것도 ts 언어임 킹받.
    const onFileChange = (e) => {
        // ts 타입 검증 대체 코드, {files} 로 직접적인 값으로 if문 작성 대신 변수값 자체에 반복문 결과를 저장해줌.
        const file = e.target.files?.[0] || null; // 파일 변수값을 확인.
        setFile(file instanceof File ? file : null); // 파일이면 저장, 아니면 상태 초기화
    };
// db 생성 코드 설정
    const onSubmit = async(e) => {
        e.preventDefault();
        const user = auth.currentUser;
        if(!user ||isLoading || shully==="" || shully.length>1800) return;
        try {
            setLoading(true);
            //게시물을 하나의 변수로 명명
           const doc = await addDoc(collection(db, "shullys"),{
                shully,
                createdAt: Date.now(),
                username: user.displayName || "Anonymous",
                userid: user.uid,
            });
            //파일이 있을경우 파일을 추가하는 코드.
            if(file){
                //저장하는 url 경로, 해당 경로는 죄가 없다.
                const locationRef = ref(
                    storage,`shullys/${user.uid}/${doc.id}`
                );
                const uploadResult = await uploadBytes(locationRef, file);
                    console.log("upload complete");
                //posting err why:  TypeError: Cannot read properties of undefined (reading 'ref') at onSubmit (bundle.js:926:104) 터미널 상 에러가 남. -> 난 snapshot 기능을 쓰기 때문에, 직접 참조변수를 받아와야 한다. then() 메소드로 인해 변수값 저장에 에러가 나서 발생됨.
                const photoURL = await getDownloadURL(uploadResult.ref);
                //serverTimestamp가 현재 작업시엔 편하지만 데이터 전송 속도측면에서 나중에 Date.now(); 로 바꿀예정 
                // const timeStamp = serverTimestamp();
                
                //fireDB에 파일 url 을 임의로 추가. json 형태로 item 명만 입력해 주는 듯.
                //저장 시간도 추적가능 하게 함.
                await updateDoc(doc, {
                        photo: photoURL,
                        // createdAt: timeStamp,
                });}                        
                setShully("");
                setFile(null); 
             } catch(e){
                    console.log("posting err why: ",e);              
                } finally{
                    setLoading(false);
                }
            };
    return (
    <PostFormWrapper onSubmit={onSubmit}>
        <PostTextArea required rows={5} maxLength={18000} value={shully} onChange={onChange}placeholder="What is happening?"/>
{/* file이란 id를 가진 value를 input 함 */}
{/* htmlFor를 AttachFileInput의 id로 설정했기에 AttachFileButton을 클릭해도 AttachFileInput의 기능을 한다. */}
        <AttachFileButton htmlFor="file">
        {file ? "Photo added ✅" : "Add photo"}
        </AttachFileButton>
{/* accept: image 파일만 허용. 확장자 제한 X 
            type: file 업로드 할 수 있는 btn 으로 바뀜
            */}     
        <AttachFileInput onChange={onFileChange} type="file" id="file" accept="image/*"/>

        <PostSubmitBtn type= "submit" value={isLoading ? "Posting..." : "Post Shully"}></PostSubmitBtn>

    </PostFormWrapper>
    );
}