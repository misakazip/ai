import { bindThis } from '@/decorators.js';
import Module from '@/module.js';
import Message from '@/message.js';

// This code is copied from this website https://gakogako.com/typescript_day_diff/
// 日付の差分を計算する関数
const formatDate = (date: Date): string => {
    const y: number = date.getFullYear();
    const m: string = ("00" + (date.getMonth() + 1)).slice(-2);
    const d: string = ("00" + date.getDate()).slice(-2);
    return `${y}-${m}-${d}`;
};

// 共通テストの日付
const setDate: Date = new Date('2025-01-18');

export default class extends Module {
	public readonly name = 'kyote';

	private diffDay: number;

	constructor() {
		super();
		// 今日の日付を取得し、setDateとの日数差を計算
		const nowDate: Date = new Date(formatDate(new Date()));
		this.diffDay = Math.floor((setDate.getTime() - nowDate.getTime()) / 86400000);
	}

	@bindThis
	public install() {
		return {
			mentionHook: this.mentionHook
		};
	}

	@bindThis
	private async mentionHook(msg: Message) {
		// メッセージに「共テ」または「共通テスト」が含まれているかを確認
		if (msg.text && (msg.text.includes('共テ') || msg.text.includes('共通テスト'))) {
			msg.reply(`共通テストまで ${Math.abs(this.diffDay)} 日です`, {
				immediate: true
			});
			return true;
		} else {
			return false;
		}
	}
}
