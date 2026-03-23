import React, { useState } from 'react';
import { auth, db, storage } from "../firebase";
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { serverTimestamp, addDoc, collection, updateDoc } from "firebase/firestore";
import { PostFormWrapper, PostTextArea, PostSubmitBtn, AttachFileButton, AttachFileInput } from "./auth-Components";

export default function Monolog() {
    const [isLoading, setLoading] = useState(false);
    const [monolog, setMonolog] = useState("");
    const [file, setFile] = useState(null);
    const [videoFile, setVideoFile] = useState(null); // 동영상 파일 상태 추가

    const onChange = (e) => {
        setMonolog(e.target.value || ""); // 문자열 아니면 공백
    };

    const onFileChange = (e) => {
        const file = e.target.files?.[0] || null;
        setFile(file instanceof File ? file : null);
    };

    const onVideoChange = (e) => {
        const videoFile = e.target.files?.[0] || null;
        setVideoFile(videoFile instanceof File ? videoFile : null);
    };

    const onSubmit = async (e) => {
        e.preventDefault();
        const user = auth.currentUser;
        if (!user || isLoading || monolog === "" || monolog.length > 1800) return;

        try {
            setLoading(true);
            const doc = await addDoc(collection(db, "monologs"), {
                monolog,
                createdAt: Date.now(),
                username: user.displayName || "Anonymous",
                userid: user.uid,
            });

            if (file) {
                const locationRef = ref(storage, `monologs/${user.uid}/${doc.id}/image`);
                const uploadResult = await uploadBytes(locationRef, file);
                const photoURL = await getDownloadURL(uploadResult.ref);
                await updateDoc(doc, { photo: photoURL });
            }

            if (videoFile) {
                const videoRef = ref(storage, `monologs/${user.uid}/${doc.id}/video`);
                const videoUploadResult = await uploadBytes(videoRef, videoFile);
                const videoURL = await getDownloadURL(videoUploadResult.ref);
                await updateDoc(doc, { video: videoURL });
            }

            setMonolog("");
            setFile(null);
            setVideoFile(null);
        } catch (e) {
            console.error("Error posting monolog:", e);
        } finally {
            setLoading(false);
        }
    };

    return (
        <PostFormWrapper onSubmit={onSubmit}>
            <PostTextArea
                required
                rows={5}
                maxLength={18000}
                value={monolog}
                onChange={onChange}
                placeholder="What is happening?"
            />

            <AttachFileButton htmlFor="file">
                {file ? "Photo added ✅" : "Add photo"}
            </AttachFileButton>
            <AttachFileInput onChange={onFileChange} type="file" id="file" accept="image/*" />

            <AttachFileButton htmlFor="video">
                {videoFile ? "Video added ✅" : "Add video"}
            </AttachFileButton>
            <AttachFileInput onChange={onVideoChange} type="file" id="video" accept="video/*" />

            <PostSubmitBtn
                type="submit"
                value={isLoading ? "Posting..." : "Post Monolog"}
            />
        </PostFormWrapper>
    );
}
